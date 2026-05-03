import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_room_model.dart';

//this repository layer interacts directly with firestore to perform CRUD operations
//it also manages room occupancy and membership
//updating this so that room occupancy is driven by study session service join and leave
class StudyRoomRepository {
  final FirebaseFirestore _firestore;

  StudyRoomRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _roomsCollection {
    return _firestore.collection('studyRooms');
  }

  //commenting this out as part of the update to move join and leave logic to study sessions
  /*CollectionReference<Map<String, dynamic>> get _userMembershipCollection {
    return _firestore.collection('studyRoomMemberships');
  }*/

  Stream<List<StudyRoom>> watchStudyRooms() {
    return _roomsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('building')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(StudyRoom.fromFirestore).toList();
        });
  }

  Future<List<StudyRoom>> getStudyRooms() async {
    final snapshot = await _roomsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('building')
        .orderBy('name')
        .get();

    return snapshot.docs.map(StudyRoom.fromFirestore).toList();
  }

  Stream<List<StudyRoom>> watchSelectableStudyRooms() {
    return _roomsCollection
        .where('isActive', isEqualTo: true)
        .where('isReservable', isEqualTo: true)
        .orderBy('building')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(StudyRoom.fromFirestore).toList();
    });
  }

  Future<List<StudyRoom>> getSelectableStudyRooms() async {
    final snapshot = await _roomsCollection
        .where('isActive', isEqualTo: true)
        .where('isReservable', isEqualTo: true)
        .orderBy('building')
        .orderBy('name')
        .get();

    return snapshot.docs.map(StudyRoom.fromFirestore).toList();
  }

  Stream<List<StudyRoom>> watchAvailableStudyRooms() {
    return _roomsCollection
        .where('isActive', isEqualTo: true)
        .where('isFull', isEqualTo: false)
        .orderBy('building')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(StudyRoom.fromFirestore).toList();
        });
  }

  Future<List<StudyRoom>> getAvailableStudyRooms() async {
    final snapshot = await _roomsCollection
        .where('isActive', isEqualTo: true)
        .where('isFull', isEqualTo: false)
        .orderBy('building')
        .orderBy('name')
        .get();

    return snapshot.docs.map(StudyRoom.fromFirestore).toList();
  }

  Stream<List<StudyRoom>> watchRoomsByBuilding(String building) {
    return _roomsCollection
        .where('isActive', isEqualTo: true)
        .where('building', isEqualTo: building)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(StudyRoom.fromFirestore).toList();
        });
  }

  //commenting this out as part of the update to move join and leave logic to study sessions
  /*Stream<String?> watchCurrentJoinedRoomId(String userId) {
    return _userMembershipCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final roomId = snapshot.data()?['roomId'];
      if (roomId is String) {
        return roomId;
      }

      return null;
    });
  }*/

  Future<StudyRoom?> getStudyRoomById(String roomId) async {
    final doc = await _roomsCollection.doc(roomId).get();

    if (!doc.exists) {
      return null;
    }

    return StudyRoom.fromFirestore(doc);
  }

  //the methods below are really just in case
  //study rooms were seed populated using other methods
  Future<void> addStudyRoom(StudyRoom room) async {
    await _roomsCollection.add({
      ...room.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStudyRoom(StudyRoom room) async {
    await _roomsCollection.doc(room.id).update({
      ...room.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deactivateStudyRoom(String roomId) async {
    await _roomsCollection.doc(roomId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /*
  commenting this out as part of the update to move join and leave logic to study sessions
  //this method determines if a user is currently checked into the given room
  //the global membership collection is checked first to enforce the one room at a time rule
  Future<bool> isUserInRoom({
    required String roomId,
    required String userId,
  }) async {
    final userMembershipDoc = await _userMembershipCollection.doc(userId).get();
    if (userMembershipDoc.exists) {
      final joinedRoomId = userMembershipDoc.data()?['roomId'];
      if (joinedRoomId is String) {
        return joinedRoomId == roomId;
      }
    }

    //this is really just a fallback, checking the rooms subcollection of members
    final memberDoc = await _roomsCollection
        .doc(roomId)
        .collection('members')
        .doc(userId)
        .get();

    return memberDoc.exists;
  }

  //this method will attempt to add a user to a room
  //after performing various checks guarded by a firestore transaction
  Future<bool> joinRoom({
    required String roomId,
    required String userId,
  }) async {
    //references to room, user membership in this room, and user's global study room membership
    final roomRef = _roomsCollection.doc(roomId);
    final memberRef = roomRef.collection('members').doc(userId);
    final userMembershipRef = _userMembershipCollection.doc(userId);

    return _firestore.runTransaction<bool>((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);

      if (!roomSnapshot.exists) {
        throw Exception('Study room not found.');
      }

      final room = StudyRoom.fromFirestore(roomSnapshot);

      if (!room.isActive) {
        throw Exception('Study room is not active.');
      }
      //is user checked in to another room already
      final userMembershipSnapshot = await transaction.get(userMembershipRef);
      if (userMembershipSnapshot.exists) {
        return false;
      }
      //is user checked in to this specific room already
      final memberSnapshot = await transaction.get(memberRef);
      if (memberSnapshot.exists) {
        return false;
      }

      if (room.isFull) {
        return false;
      }

      final newOccupancy = room.currentOccupancy + 1;
      //add user to this room's members collection
      transaction.set(memberRef, {
        'userId': userId,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      //add user to this room in the global room membership collection
      transaction.set(userMembershipRef, {
        'roomId': roomId,
        'userId': userId,
        'joinedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      //update room document
      transaction.update(roomRef, {
        'currentOccupancy': newOccupancy,
        'isFull': newOccupancy >= room.capacity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  //this method also uses a firestore transaction to ensure that occupancy is updated correctly
  //the transaction checks help the repository update multiple data points after one event
  Future<bool> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    //references to room, user membership in this room, and user's global study room membership
    final roomRef = _roomsCollection.doc(roomId);
    final memberRef = roomRef.collection('members').doc(userId);
    final userMembershipRef = _userMembershipCollection.doc(userId);

    return _firestore.runTransaction<bool>((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);

      if (!roomSnapshot.exists) {
        throw Exception('Study room not found.');
      }

      final memberSnapshot = await transaction.get(memberRef);
      final userMembershipSnapshot = await transaction.get(userMembershipRef);
      //does global study room membership show this uer in this room
      final joinedRoomId = userMembershipSnapshot.data()?['roomId'];
      final isMembershipForRoom =
          joinedRoomId is String && joinedRoomId == roomId;

      //user not member of this room but global study room membership says yes
      if (!memberSnapshot.exists) {
        if (isMembershipForRoom) {
          transaction.delete(userMembershipRef);
        }

        return false;
      }

      final room = StudyRoom.fromFirestore(roomSnapshot);
      final newOccupancy = room.currentOccupancy > 0
          ? room.currentOccupancy - 1
          : 0;
      //remove user from members subcollection of the room document
      //and global study room membership if it exists
      transaction.delete(memberRef);
      if (isMembershipForRoom) {
        transaction.delete(userMembershipRef);
      }
      //update study room document values
      transaction.update(roomRef, {
        'currentOccupancy': newOccupancy,
        'isFull': newOccupancy >= room.capacity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }
  */
}
