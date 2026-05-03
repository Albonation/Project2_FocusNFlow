//basic CRUD operations for working with the firestore study group collections

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/group_member_model.dart';
import '../models/study_group_model.dart';

class StudyGroupRepository {
  final FirebaseFirestore _firestore;

  StudyGroupRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _groupsRef {
    return _firestore.collection('study_groups');
  }

  //stream active groups from firestore
  Stream<List<StudyGroup>> watchActiveGroups() {
    return _groupsRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StudyGroup.fromFirestore(doc))
              .toList(),
        );
  }

  //stream members of a specific group
  Stream<List<GroupMember>> watchGroupMembers(String groupId) {
    _validateGroupId(groupId);

    return _groupsRef
        .doc(groupId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GroupMember.fromFirestore(doc))
              .toList(),
        );
  }

  //fetch a single study group given a group id
  Future<StudyGroup?> getGroupById(String groupId) async {
    try {
      _validateGroupId(groupId);

      final doc = await _groupsRef.doc(groupId).get();

      if (!doc.exists) {
        return null;
      }

      return StudyGroup.fromFirestore(doc);
    } catch (error) {
      debugPrint('Error getting study group: $error');
      rethrow;
    }
  }

  //fetch all groups that the given user belongs to
  Future<Set<String>> getUserGroupIds(String userId) async {
    try {
      _validateUserId(userId);

      final isMemberOfSnapshot = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: userId)
          .get();

      return isMemberOfSnapshot.docs
          .map((doc) => doc.reference.parent.parent?.id)
          .whereType<String>()
          .toSet();
    } catch (error) {
      debugPrint('Error getting user group ids: $error');
      rethrow;
    }
  }

  //check if a given user is a member of a given group
  Future<bool> isUserMemberOfGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      _validateGroupId(groupId);
      _validateUserId(userId);

      final memberDoc = await _groupsRef
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .get();

      return memberDoc.exists;
    } catch (error) {
      debugPrint('Error checking group membership: $error');
      rethrow;
    }
  }

  //create a new study group and add creating user as owner
  //uses a batch so the group doc and owner are written together
  Future<String> createGroup({
    required StudyGroup group,
    required GroupMember owner,
  }) async {
    try {
      _validateGroupCreation(group);
      _validateMember(owner);

      //create local doc refs
      final groupRef = _groupsRef.doc();
      final ownerRef = groupRef.collection('members').doc(owner.userId);

      //store generated firestone id in a copy
      final groupWithId = group.copyWith(id: groupRef.id);

      final batch = _firestore.batch();

      //queue up the doc writes
      batch.set(groupRef, groupWithId.toFirestore());
      batch.set(ownerRef, owner.toFirestore());

      //commit both writes together
      await batch.commit();

      return groupRef.id;
    } catch (error) {
      debugPrint('Error creating study group: $error');
      rethrow;
    }
  }

  //join a user to an active study group
  //uses a transaction because the method needs to read group and member state
  //before safely creating the member doc and incrementing member count
  Future<void> joinGroup({
    required String groupId,
    required GroupMember member,
  }) async {
    try {
      _validateGroupId(groupId);
      _validateMember(member);

      //create reference to group
      final groupRef = _groupsRef.doc(groupId);
      //create reference to user membership doc
      //avoiding duplicates by using userId as doc Id.
      final memberRef = groupRef.collection('members').doc(member.userId);

      await _firestore.runTransaction((transaction) async {
        //read group and member docs inside transaction
        final groupSnapshot = await transaction.get(groupRef);
        final memberSnapshot = await transaction.get(memberRef);

        //check if group still exists
        if (!groupSnapshot.exists) {
          throw Exception('Study group no longer exists.');
        }

        final groupData = groupSnapshot.data();

        //check if group is still active
        final isActive = groupData?['isActive'] == true;
        if (!isActive) {
          throw Exception('This study group is not active.');
        }

        //check if member already in group
        if (memberSnapshot.exists) {
          throw Exception('You are already a member of this group.');
        }

        //create user's membership doc in group's members subcollection
        transaction.set(memberRef, member.toFirestore());

        //update memberCount and time of update
        transaction.update(groupRef, {
          'memberCount': FieldValue.increment(1),
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (error) {
      debugPrint('Error joining study group: $error');
      rethrow;
    }
  }

  //leave a given group for a given user
  //uses a transaction because the method needs to read group and member state
  //before safely deleting the membership doc and reducing the member count
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      _validateGroupId(groupId);
      _validateUserId(userId);

      //create reference to group doc and membership doc
      final groupRef = _groupsRef.doc(groupId);
      final memberRef = groupRef.collection('members').doc(userId);

      await _firestore.runTransaction((transaction) async {
        //read group and member docs inside the transaction
        final groupSnapshot = await transaction.get(groupRef);
        final memberSnapshot = await transaction.get(memberRef);

        //check if group exists
        if (!groupSnapshot.exists) {
          throw Exception('Study group no longer exists.');
        }

        //check if user is a member of this group
        if (!memberSnapshot.exists) {
          throw Exception('You are not a member of this group.');
        }

        //check if user is the owner of group and block leave if so
        final memberData = memberSnapshot.data();
        final role = memberData?['role'] ?? GroupMember.memberRole;
        if (role == GroupMember.ownerRole) {
          throw Exception(
            'Group owners cannot leave yet. Delete the group instead.',
          );
        }

        //delete this user's membership doc from the group's member subcollection
        transaction.delete(memberRef);

        //decrement the group's memberCount and refresh updatedAt
        transaction.update(groupRef, {
          'memberCount': FieldValue.increment(-1),
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (error) {
      debugPrint('Error leaving study group: $error');
      rethrow;
    }
  }

  //update an existing group
  //uses a transaction to verify that the requesting user owns the group
  //before changing the group's editable fields.
  Future<void> updateGroup({
    required String groupId,
    required String userId,
    required String name,
    required String description,
  }) async {
    try {
      _validateGroupId(groupId);
      _validateUserId(userId);
      _validateGroupText(name);

      //reference to the group document
      final groupRef = _groupsRef.doc(groupId);

      await _firestore.runTransaction((transaction) async {
        //read the group document inside the transaction so ownership and
        //active status are checked against the latest firestore state
        final groupSnapshot = await transaction.get(groupRef);
        final groupData = groupSnapshot.data();

        //check if group exists
        if (!groupSnapshot.exists || groupData == null) {
          throw Exception('Study group no longer exists.');
        }

        //check if user is owner of group
        if (groupData['createdBy'] != userId) {
          throw Exception('Only the group owner can update this group.');
        }

        //check if group is active
        final isActive = groupData['isActive'] == true;
        if (!isActive) {
          throw Exception('This study group is not active.');
        }

        //update the editable group fields and refresh updatedAt
        transaction.update(groupRef, {
          'name': name.trim(),
          'description': description.trim(),
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (error) {
      debugPrint('Error updating study group: $error');
      rethrow;
    }
  }

  //deactivate an existing group
  //uses a transaction to verify ownership before deactivating the group
  Future<void> deactivateGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      _validateGroupId(groupId);
      _validateUserId(userId);

      //create reference to document
      final groupRef = _groupsRef.doc(groupId);

      await _firestore.runTransaction((transaction) async {
        //read group inside transaction
        final groupSnapshot = await transaction.get(groupRef);
        final groupData = groupSnapshot.data();

        //check if group still exists
        if (!groupSnapshot.exists || groupData == null) {
          throw Exception('Study group no longer exists.');
        }

        //check if group is not active
        final isActive = groupData['isActive'] == true;
        if (!isActive) {
          throw Exception('This study group is already inactive.');
        }

        //check if given user is owner
        if (groupData['createdBy'] != userId) {
          throw Exception('Only the group owner can delete this group.');
        }

        //soft delete the group by marking it not active and refresh updatedAt
        transaction.update(groupRef, {
          'isActive': false,
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (error) {
      debugPrint('Error deactivating study group: $error');
      rethrow;
    }
  }

  //helper methods for validation
  void _validateGroupId(String groupId) {
    if (groupId.trim().isEmpty) {
      throw Exception('Invalid study group.');
    }
  }

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception('Invalid user.');
    }
  }

  void _validateMember(GroupMember member) {
    _validateUserId(member.userId);

    if (member.role.trim().isEmpty) {
      throw Exception('Invalid group member role.');
    }
  }

  void _validateGroupCreation(StudyGroup group) {
    if (group.name.trim().isEmpty) {
      throw Exception('Group name is required.');
    }

    if (group.createdBy.trim().isEmpty) {
      throw Exception('Group owner is required.');
    }

    if (group.memberCount < 1) {
      throw Exception('Group member count must start at 1.');
    }
  }

  void _validateGroupText(String name) {
    if (name.trim().isEmpty) {
      throw Exception('Group name is required.');
    }
  }
}
