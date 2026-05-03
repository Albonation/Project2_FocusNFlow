import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_member_model.dart';
import '../models/study_group_model.dart';
import '../repositories/study_group_repository.dart';

///handles study group logic between the UI and repository.
///this service is responsible for:
/// - checking the current firebase user
/// - validating user-facing form input
/// - creating study group and group member model objects
/// - calling the repository
/// - converting repository errors into UI-friendly action results
class StudyGroupService {
  final StudyGroupRepository _repository;
  final FirebaseAuth _auth;

  StudyGroupService({StudyGroupRepository? repository, FirebaseAuth? auth})
    : _repository = repository ?? StudyGroupRepository(),
      _auth = auth ?? FirebaseAuth.instance;

  //stream all active study groups
  Stream<List<StudyGroup>> watchActiveGroups() {
    return _repository.watchActiveGroups();
  }

  //stream the members of a specific study group
  Stream<List<GroupMember>> watchGroupMembers(String groupId) {
    final error = _validateGroupId(groupId);

    if (error != null) {
      return Stream.value([]);
    }

    return _repository.watchGroupMembers(groupId);
  }

  //fetch all groups that the user belongs to
  Future<Set<String>> getCurrentUserGroupIds() async {
    final user = _currentUser;

    final error = _runValidation([
          () => _validateSignedIn(user, 'load your study groups'),
    ]);

    if (error != null) {
      return {};
    }

    return _repository.getUserGroupIds(user!.uid);
  }

  //check whether the current user is a member of a given group
  Future<bool> isCurrentUserMemberOfGroup(String groupId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'check group membership'),
      () => _validateGroupId(groupId),
    ]);

    if (error != null) {
      return false;
    }

    return _repository.isUserMemberOfGroup(groupId: groupId, userId: user!.uid);
  }

  //check whether the current user owns a given group
  bool isCurrentUserGroupOwner(StudyGroup group) {
    final user = _currentUser;

    if (user == null) {
      return false;
    }

    return group.createdBy == user.uid;
  }

  //create a new study group after validating the form fields and current user
  Future<StudyGroupActionResult> createGroup({
    required String name,
    required String description,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'create a group'),
      () => _validateGroupFormFields(name: name, description: description),
    ]);

    if (error != null) {
      return _failureResult(error);
    }

    try {
      final now = DateTime.now();

      final group = StudyGroup(
        id: '',
        name: name.trim(),
        description: description.trim(),
        createdBy: user!.uid,
        createdAt: now,
        updatedAt: now,
        memberCount: 1,
        isActive: true,
      );

      final owner = GroupMember(
        userId: user.uid,
        displayName: _resolveDisplayName(user),
        email: user.email ?? '',
        role: GroupMember.ownerRole,
        joinedAt: now,
      );

      final groupId = await _repository.createGroup(group: group, owner: owner);

      return _successResult(
        'Study group created successfully.',
        groupId: groupId,
      );
    } catch (error) {
      return _failureResult(
        'Failed to create study group: ${_cleanError(error)}',
      );
    }
  }

  //join the current user to an existing study group after validation
  Future<StudyGroupActionResult> joinGroup(String groupId) async {
    final user = _currentUser;
    final now = DateTime.now();

    final error = _runValidation([
      () => _validateSignedIn(user, 'join a group'),
      () => _validateGroupId(groupId),
    ]);

    if (error != null) {
      return _failureResult(error);
    }

    try {
      final member = GroupMember(
        userId: user!.uid,
        displayName: _resolveDisplayName(user),
        email: user.email ?? '',
        role: GroupMember.memberRole,
        joinedAt: now,
      );

      await _repository.joinGroup(groupId: groupId, member: member);

      return _successResult(
        'Joined study group successfully.',
        groupId: groupId,
      );
    } catch (error) {
      return _failureResult(_cleanError(error));
    }
  }

  //remove the current user from an existing study group after validation
  Future<StudyGroupActionResult> leaveGroup(String groupId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'leave a group'),
      () => _validateGroupId(groupId),
    ]);

    if (error != null) {
      return _failureResult(error);
    }

    try {
      await _repository.leaveGroup(groupId: groupId, userId: user!.uid);

      return _successResult('Left study group successfully.', groupId: groupId);
    } catch (error) {
      return _failureResult(_cleanError(error));
    }
  }

  //update an existing study group after validating the current user and form fields
  Future<StudyGroupActionResult> updateGroup({
    required String groupId,
    required String name,
    required String description,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'update a group'),
      () => _validateGroupId(groupId),
      () => _validateGroupFormFields(name: name, description: description),
    ]);

    if (error != null) {
      return _failureResult(error);
    }

    try {
      await _repository.updateGroup(
        groupId: groupId,
        userId: user!.uid,
        name: name,
        description: description,
      );

      return _successResult(
        'Study group updated successfully.',
        groupId: groupId,
      );
    } catch (error) {
      return _failureResult(
        'Failed to update study group: ${_cleanError(error)}',
      );
    }
  }

  //soft-delete an existing group after validating the current user and group id
  Future<StudyGroupActionResult> deactivateGroup(String groupId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'delete a group'),
      () => _validateGroupId(groupId),
    ]);

    if (error != null) {
      return _failureResult(error);
    }

    try {
      await _repository.deactivateGroup(groupId: groupId, userId: user!.uid);

      return _successResult(
        'Study group deleted successfully.',
        groupId: groupId,
      );
    } catch (error) {
      return _failureResult(_cleanError(error));
    }
  }

  //helper methods for validation
  User? get _currentUser => _auth.currentUser;

  String? _validateSignedIn(User? user, String action) {
    if (user == null) {
      return 'You must be signed in to $action.';
    }

    return null;
  }

  String? _validateGroupId(String? groupId) {
    if (groupId == null || groupId.trim().isEmpty) {
      return 'Invalid study group.';
    }

    return null;
  }

  String? _validateGroupName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Group name is required.';
    }

    if (name.trim().length < 3) {
      return 'Group name must be at least 3 characters.';
    }

    return null;
  }

  String? _validateGroupDescription(String? description) {
    if (description != null && description.trim().length > 500) {
      return 'Description must be 500 characters or less.';
    }

    return null;
  }

  String? _validateGroupFormFields({
    required String name,
    required String description,
  }) {
    return _runValidation([
      () => _validateGroupName(name),
      () => _validateGroupDescription(description),
    ]);
  }

  String? _runValidation(List<String? Function()> checks) {
    for (final check in checks) {
      final result = check();

      if (result != null) {
        return result;
      }
    }

    return null;
  }

  StudyGroupActionResult _failureResult(String message) {
    return StudyGroupActionResult.failure(message);
  }

  StudyGroupActionResult _successResult(String message, {String? groupId}) {
    return StudyGroupActionResult.success(message, groupId: groupId);
  }

  //returns a display name for group membership records
  String _resolveDisplayName(User user) {
    final displayName = user.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email;

    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Student';
  }

  //modifies repository exceptions for display in snackbars or dialogs
  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

///result object for study group actions.
class StudyGroupActionResult {
  final bool success;
  final String message;
  final String? groupId;

  const StudyGroupActionResult({
    required this.success,
    required this.message,
    this.groupId,
  });

  factory StudyGroupActionResult.success(String message, {String? groupId}) {
    return StudyGroupActionResult(
      success: true,
      message: message,
      groupId: groupId,
    );
  }

  factory StudyGroupActionResult.failure(String message) {
    return StudyGroupActionResult(success: false, message: message);
  }
}
