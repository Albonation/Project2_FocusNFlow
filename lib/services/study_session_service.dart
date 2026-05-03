import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/study_session_model.dart';
import 'package:focus_n_flow/repositories/study_session_repository.dart';
import '../models/session_participant_model.dart';

class StudySessionService {
  final StudySessionRepository _repository;
  final FirebaseAuth _auth;

  StudySessionService({StudySessionRepository? repository, FirebaseAuth? auth})
    : _repository = repository ?? StudySessionRepository(),
      _auth = auth ?? FirebaseAuth.instance;

  /*
  streams and fetchers
   */
  Stream<List<StudySession>> watchSessionsForGroup(String groupId) {
    return _repository.watchSessionsForGroup(groupId);
  }

  Stream<StudySession?> watchSession(String sessionId) {
    return _repository.watchSession(sessionId);
  }

  Stream<List<SessionParticipant>> watchParticipants(String sessionId) {
    return _repository.watchParticipants(sessionId);
  }

  Future<List<StudySession>> getOverlappingRoomSessions({
    required String roomId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? ignoreSessionId,
  }) {
    return _repository.getOverlappingRoomSessions(
      roomId: roomId,
      startsAt: startsAt,
      endsAt: endsAt,
      ignoreSessionId: ignoreSessionId,
    );
  }

  /*
  create and edit sessions
   */
  Future<StudySessionActionResult> createSession({
    required String groupId,
    required String groupName,
    required String title,
    required String description,
    required DateTime startsAt,
    required DateTime endsAt,
    String? courseId,
    String? courseCode,
    String? roomId,
    String? roomName,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'create a study session'),
      () => _validateGroupId(groupId),
      () => _validateGroupName(groupName),
      () => _validateSessionTitle(title),
      () => _validateSessionDescription(description),
      () => _validateSessionTimes(startsAt: startsAt, endsAt: endsAt),
      () =>
          _validateCourseSelection(courseId: courseId, courseCode: courseCode),
      () => _validateRoomSelection(roomId: roomId, roomName: roomName),
    ]);

    if (error != null) {
      return StudySessionActionResult.failure(error);
    }

    try {
      //service level permission check
      final isMember = await _repository.isUserGroupMember(
        groupId: groupId,
        userId: user!.uid,
      );

      if (!isMember) {
        return StudySessionActionResult.failure(
          'You must be a member of this group to create a session.',
        );
      }

      //no session to ignore when creating a session and checking for conflicts
      final cleanedRoomId = _cleanNullable(roomId);
      if (cleanedRoomId != null) {
        final hasConflict = await _repository.hasRoomScheduleConflict(
          roomId: cleanedRoomId,
          startsAt: startsAt,
          endsAt: endsAt,
        );

        if (hasConflict) {
          return StudySessionActionResult.failure(
            'This study room is already scheduled during that time.',
          );
        }
      }

      final now = DateTime.now();

      //##TODO when room selection is wired in, handle immediately active session
      final status = startsAt.isAfter(now)
          ? StudySessionStatus.scheduled
          : StudySessionStatus.active;

      final session = StudySession(
        id: '',
        groupId: groupId.trim(),
        groupName: groupName.trim(),
        title: title.trim(),
        description: description.trim(),
        courseId: _cleanNullable(courseId),
        courseCode: _cleanNullable(courseCode),
        roomId: cleanedRoomId,
        roomName: _cleanNullable(roomName),
        createdBy: user.uid,
        createdByName: _resolveDisplayName(user),
        createdAt: null,
        updatedAt: null,
        startsAt: startsAt,
        endsAt: endsAt,
        status: status,
        participantCount: 0,
        reminderSent: false,
        isActive: true,
        startedBy: status == StudySessionStatus.active ? user.uid : null,
      );

      final sessionId = await _repository.createSession(session);

      return StudySessionActionResult.success(
        message: 'Study session created successfully.',
        sessionId: sessionId,
      );
    } catch (error) {
      return StudySessionActionResult.failure(_cleanError(error));
    }
  }

  Future<StudySessionActionResult> updateSession({
    required StudySession session,
    required String title,
    required String description,
    required DateTime startsAt,
    required DateTime endsAt,
    String? courseId,
    String? courseCode,
    String? roomId,
    String? roomName,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'update a study session'),
      () => _validateEditableSession(session),
      () => _validateSessionCreator(session: session, user: user!),
      () => _validateSessionTitle(title),
      () => _validateSessionDescription(description),
      () => _validateSessionTimes(startsAt: startsAt, endsAt: endsAt),
      () =>
          _validateCourseSelection(courseId: courseId, courseCode: courseCode),
      () => _validateRoomSelection(roomId: roomId, roomName: roomName),
    ]);

    if (error != null) {
      return StudySessionActionResult.failure(error);
    }

    try {
      final cleanedRoomId = _cleanNullable(roomId);

      //ignoring the session in context when checking for conflicts
      if (cleanedRoomId != null) {
        final hasConflict = await _repository.hasRoomScheduleConflict(
          roomId: cleanedRoomId,
          startsAt: startsAt,
          endsAt: endsAt,
          ignoreSessionId: session.id,
        );

        if (hasConflict) {
          return StudySessionActionResult.failure(
            'This study room is already scheduled during that time.',
          );
        }
      }

      final updatedSession = session.copyWith(
        title: title.trim(),
        description: description.trim(),
        startsAt: startsAt,
        endsAt: endsAt,
        courseId: _cleanNullable(courseId),
        courseCode: _cleanNullable(courseCode),
        roomId: cleanedRoomId,
        roomName: _cleanNullable(roomName),
      );

      await _repository.updateSession(updatedSession);

      return StudySessionActionResult.success(
        message: 'Study session updated.',
        sessionId: session.id,
      );
    } catch (error) {
      return StudySessionActionResult.failure(_cleanError(error));
    }
  }

  /*
  session lifecycle actions
   */
  Future<StudySessionActionResult> startSession(String sessionId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'start a study session'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return StudySessionActionResult.failure(error);
    }

    try {
      await _repository.startSession(
        sessionId: sessionId.trim(),
        userId: user!.uid,
      );

      return StudySessionActionResult.success(
        message: 'Study session started.',
        sessionId: sessionId,
      );
    } catch (error) {
      return StudySessionActionResult.failure(_cleanError(error));
    }
  }

  Future<StudySessionActionResult> cancelSession(String sessionId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'cancel a study session'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return StudySessionActionResult.failure(error);
    }

    try {
      await _repository.cancelSession(sessionId: sessionId.trim());

      return StudySessionActionResult.success(
        message: 'Study session cancelled.',
        sessionId: sessionId,
      );
    } catch (error) {
      return StudySessionActionResult.failure(_cleanError(error));
    }
  }

  Future<StudySessionActionResult> completeSession(String sessionId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'complete a study session'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return StudySessionActionResult.failure(error);
    }

    try {
      await _repository.completeSession(sessionId: sessionId.trim());

      return StudySessionActionResult.success(
        message: 'Study session completed.',
        sessionId: sessionId,
      );
    } catch (error) {
      return StudySessionActionResult.failure(_cleanError(error));
    }
  }

  /*
  session participation actions
   */
  Future<StudySessionActionResult> joinSession(String sessionId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'join a study session'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return StudySessionActionResult.failure(error);
    }

    try {
      await _repository.joinSessionTransaction(
        sessionId: sessionId.trim(),
        userId: user!.uid,
        displayName: _resolveDisplayName(user),
        email: user.email ?? '',
      );

      return StudySessionActionResult.success(
        message: 'You joined the study session.',
        sessionId: sessionId,
      );
    } catch (error) {
      return StudySessionActionResult.failure(_cleanError(error));
    }
  }

  Future<StudySessionActionResult> leaveSession(String sessionId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'leave a study session'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return StudySessionActionResult.failure(error);
    }

    try {
      await _repository.leaveSessionTransaction(
        sessionId: sessionId.trim(),
        userId: user!.uid,
      );

      return StudySessionActionResult.success(
        message: 'You left the study session.',
        sessionId: sessionId,
      );
    } catch (error) {
      return StudySessionActionResult.failure(_cleanError(error));
    }
  }

  /*
  validation helper methods
   */
  String? get currentUserId => _auth.currentUser?.uid;
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

  String? _validateGroupName(String? groupName) {
    if (groupName == null || groupName.trim().isEmpty) {
      return 'Invalid study group name.';
    }

    return null;
  }

  String? _validateSessionId(String? sessionId) {
    if (sessionId == null || sessionId.trim().isEmpty) {
      return 'Invalid study session.';
    }

    return null;
  }

  String? _validateSessionTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Please enter a session title.';
    }

    if (title.trim().length > 100) {
      return 'Session title must be 100 characters or less.';
    }

    return null;
  }

  String? _validateSessionDescription(String? description) {
    if (description != null && description.trim().length > 500) {
      return 'Session description must be 500 characters or less.';
    }

    return null;
  }

  String? _validateSessionTimes({
    required DateTime startsAt,
    required DateTime endsAt,
    bool requireFutureEnd = true,
  }) {
    if (!startsAt.isBefore(endsAt)) {
      return 'The start time must be before the end time.';
    }

    if (requireFutureEnd && !endsAt.isAfter(DateTime.now())) {
      return 'The session end time must be in the future.';
    }

    return null;
  }

  String? _validateEditableSession(StudySession session) {
    if (session.id.trim().isEmpty) {
      return 'Invalid study session.';
    }

    if (session.status == StudySessionStatus.cancelled) {
      return 'Cancelled sessions cannot be edited.';
    }

    if (session.status == StudySessionStatus.completed) {
      return 'Completed sessions cannot be edited.';
    }

    if (session.status == StudySessionStatus.active) {
      return 'Active sessions cannot be rescheduled. Complete or cancel this session first.';
    }

    return null;
  }

  String? _validateSessionCreator({
    required StudySession session,
    required User user,
  }) {
    if (session.createdBy != user.uid) {
      return 'Only the session creator can edit this session.';
    }

    return null;
  }

  String? _validateRoomSelection({
    required String? roomId,
    required String? roomName,
  }) {
    final hasRoomId = roomId != null && roomId.trim().isNotEmpty;
    final hasRoomName = roomName != null && roomName.trim().isNotEmpty;

    if (hasRoomId != hasRoomName) {
      return 'Selected room information is incomplete.';
    }

    return null;
  }

  String? _validateCourseSelection({
    required String? courseId,
    required String? courseCode,
  }) {
    final hasCourseId = courseId != null && courseId.trim().isNotEmpty;
    final hasCourseCode = courseCode != null && courseCode.trim().isNotEmpty;

    if (hasCourseId != hasCourseCode) {
      return 'Selected course information is incomplete.';
    }

    return null;
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

  /*
  formatting helpers
   */
  String _resolveDisplayName(User user) {
    final displayName = user.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();

    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Student';
  }

  String? _cleanNullable(String? value) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

class StudySessionActionResult {
  final bool success;
  final String message;
  final String? sessionId;

  const StudySessionActionResult({
    required this.success,
    required this.message,
    this.sessionId,
  });

  factory StudySessionActionResult.success({
    required String message,
    String? sessionId,
  }) {
    return StudySessionActionResult(
      success: true,
      message: message,
      sessionId: sessionId,
    );
  }

  factory StudySessionActionResult.failure(String message) {
    return StudySessionActionResult(success: false, message: message);
  }
}
