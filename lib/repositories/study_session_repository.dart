import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/session_participant_model.dart';
import 'package:focus_n_flow/models/study_session_model.dart';

class StudySessionRepository {
  final FirebaseFirestore _firestore;

  StudySessionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  //top level study sessions collection
  CollectionReference<Map<String, dynamic>> get _sessionsRef {
    return _firestore.collection('study_sessions');
  }

  //a document for each individual study session
  DocumentReference<Map<String, dynamic>> _sessionRef(String sessionId) {
    return _sessionsRef.doc(sessionId);
  }

  //sub collection of a single study session to store participants of that session
  CollectionReference<Map<String, dynamic>> _participantsRef(String sessionId) {
    return _sessionRef(sessionId).collection('participants');
  }

  //an individual participant of a study session
  DocumentReference<Map<String, dynamic>> _participantRef({
    required String sessionId,
    required String userId,
  }) {
    return _participantsRef(sessionId).doc(userId);
  }

  //reference to existing group member document
  DocumentReference<Map<String, dynamic>> _groupMemberRef({
    required String groupId,
    required String userId,
  }) {
    return _firestore
        .collection('study_groups')
        .doc(groupId)
        .collection('members')
        .doc(userId);
  }

  //reference to an existing study room document
  DocumentReference<Map<String, dynamic>> _roomRef(String roomId) {
    return _firestore.collection('studyRooms').doc(roomId);
  }

  /*
  stream and fetch methods
   */
  Stream<List<StudySession>> watchSessionsForGroup(String groupId) {
    _validateGroupId(groupId);

    return _sessionsRef
        .where('groupId', isEqualTo: groupId)
        .where('isActive', isEqualTo: true)
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(StudySession.fromFirestore).toList();
        });
  }

  Stream<StudySession?> watchSession(String sessionId) {
    _validateSessionId(sessionId);

    return _sessionRef(sessionId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StudySession.fromFirestore(doc);
    });
  }

  Stream<List<SessionParticipant>> watchParticipants(String sessionId) {
    _validateSessionId(sessionId);

    return _participantsRef(sessionId)
        .where('status', isEqualTo: SessionParticipantStatus.joined.value)
        .orderBy('joinedAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(SessionParticipant.fromFirestore).toList();
        });
  }

  //adding this method to allow for viewing upcoming study sessions on dashboard
  Stream<List<StudySession>> watchUpcomingScheduledSessions({
    required DateTime startsAfter,
    required DateTime startsBefore,
  }) {
    return _sessionsRef
        .where('isActive', isEqualTo: true)
        .where('status', isEqualTo: StudySessionStatus.scheduled.value)
        .where(
          'startsAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startsAfter),
        )
        .where('startsAt', isLessThan: Timestamp.fromDate(startsBefore))
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(StudySession.fromFirestore).toList();
        });
  }

  Future<bool> isUserGroupMember({
    required String groupId,
    required String userId,
  }) async {
    _validateGroupId(groupId);
    _validateUserId(userId);

    final memberDoc = await _groupMemberRef(
      groupId: groupId,
      userId: userId,
    ).get();

    return memberDoc.exists;
  }

  Future<bool> hasRoomScheduleConflict({
    required String roomId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? ignoreSessionId,
  }) async {
    final conflicts = await getOverlappingRoomSessions(
      roomId: roomId,
      startsAt: startsAt,
      endsAt: endsAt,
      ignoreSessionId: ignoreSessionId,
    );

    return conflicts.isNotEmpty;
  }

  Future<List<StudySession>> getOverlappingRoomSessions({
    required String roomId,
    required DateTime startsAt,
    required DateTime endsAt,
    String? ignoreSessionId,
  }) async {
    _validateRoomId(roomId);
    _validateSessionTimes(startsAt: startsAt, endsAt: endsAt);

    //narrow the search to sessions in the room that start before
    //the new session ends
    final snapshot = await _sessionsRef
        .where('roomId', isEqualTo: roomId)
        .where('isActive', isEqualTo: true)
        .where('startsAt', isLessThan: Timestamp.fromDate(endsAt))
        .get();

    return snapshot.docs.map(StudySession.fromFirestore).where((session) {
      if (ignoreSessionId != null && session.id == ignoreSessionId) {
        return false;
      }

      if (session.status == StudySessionStatus.cancelled ||
          session.status == StudySessionStatus.completed) {
        return false;
      }

      return startsAt.isBefore(session.endsAt) &&
          endsAt.isAfter(session.startsAt);
    }).toList();
  }

  /*
  CRUD and lifecycle operations
   */
  Future<String> createSession(StudySession session) async {
    _validateStudySession(session);

    final docRef = await _sessionsRef.add(session.toFirestore());
    return docRef.id;
  }

  Future<void> updateSession(StudySession session) async {
    _validateSessionId(session.id);
    _validateStudySession(session);

    await _sessionRef(session.id).update(session.toUpdateFirestore());
  }

  Future<void> startSession({
    required String sessionId,
    required String userId,
  }) async {
    _validateSessionId(sessionId);
    _validateUserId(userId);

    await _firestore.runTransaction((transaction) async {
      final sessionRef = _sessionRef(sessionId);
      final sessionDoc = await transaction.get(sessionRef);

      if (!sessionDoc.exists) {
        throw Exception('Study session was not found.');
      }

      final data = sessionDoc.data() ?? {};
      final status = data['status'] as String? ?? '';
      final roomId = data['roomId'] as String?;
      final title = data['title'] as String? ?? 'Study Session';
      final groupId = data['groupId'] as String? ?? '';
      final groupName = data['groupName'] as String? ?? '';

      if (status == StudySessionStatus.cancelled.value) {
        throw Exception('This study session has been cancelled.');
      }

      if (status == StudySessionStatus.completed.value) {
        throw Exception('This study session has already been completed.');
      }

      if (status == StudySessionStatus.active.value) {
        throw Exception('This study session is already active.');
      }

      if (roomId != null && roomId.trim().isNotEmpty) {
        final roomRef = _roomRef(roomId);
        final roomDoc = await transaction.get(roomRef);

        if (!roomDoc.exists) {
          throw Exception('The selected study room was not found.');
        }

        final roomData = roomDoc.data() ?? {};
        final roomIsActive = roomData['isActive'] as bool? ?? true;
        final activeSessionId = roomData['activeSessionId'] as String?;

        if (!roomIsActive) {
          throw Exception('This study room is not currently available.');
        }

        if (activeSessionId != null &&
            activeSessionId.trim().isNotEmpty &&
            activeSessionId != sessionId) {
          throw Exception(
            'This study room is already being used by another session.',
          );
        }

        transaction.update(roomRef, {
          'activeSessionId': sessionId,
          'activeSessionTitle': title,
          'activeGroupId': groupId,
          'activeGroupName': groupName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.update(sessionRef, {
        'status': StudySessionStatus.active.value,
        'startedBy': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelSession({required String sessionId}) async {
    _validateSessionId(sessionId);

    final joinedParticipantDocs = await _getJoinedParticipantDocs(sessionId);

    await _firestore.runTransaction((transaction) async {
      final sessionRef = _sessionRef(sessionId);
      final sessionDoc = await transaction.get(sessionRef);

      if (!sessionDoc.exists) {
        throw Exception('Study session was not found.');
      }

      final sessionData = sessionDoc.data() ?? {};

      await _cleanupJoinedParticipantsAndRoomIfNeeded(
        transaction: transaction,
        sessionId: sessionId,
        sessionData: sessionData,
        joinedParticipantDocs: joinedParticipantDocs,
      );

      transaction.update(sessionRef, {
        'status': StudySessionStatus.cancelled.value,
        'participantCount': 0,
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> completeSession({required String sessionId}) async {
    _validateSessionId(sessionId);

    final joinedParticipantDocs = await _getJoinedParticipantDocs(sessionId);

    await _firestore.runTransaction((transaction) async {
      final sessionRef = _sessionRef(sessionId);
      final sessionDoc = await transaction.get(sessionRef);

      if (!sessionDoc.exists) {
        throw Exception('Study session was not found.');
      }

      final sessionData = sessionDoc.data() ?? {};

      await _cleanupJoinedParticipantsAndRoomIfNeeded(
        transaction: transaction,
        sessionId: sessionId,
        sessionData: sessionData,
        joinedParticipantDocs: joinedParticipantDocs,
      );

      transaction.update(sessionRef, {
        'status': StudySessionStatus.completed.value,
        'participantCount': 0,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _cleanupJoinedParticipantsAndRoomIfNeeded({
    required Transaction transaction,
    required String sessionId,
    required Map<String, dynamic> sessionData,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>>
    joinedParticipantDocs,
  }) async {
    final joinedParticipantCount = joinedParticipantDocs.length;
    final roomId = sessionData['roomId'] as String?;

    DocumentReference<Map<String, dynamic>>? roomRef;
    int? roomCurrentOccupancy;
    int? roomCapacity;

    if (roomId != null && roomId.trim().isNotEmpty) {
      roomRef = _roomRef(roomId.trim());
      final roomDoc = await transaction.get(roomRef);

      if (roomDoc.exists) {
        final roomData = roomDoc.data() ?? {};

        roomCurrentOccupancy =
            (roomData['currentOccupancy'] as num?)?.toInt() ?? 0;
        roomCapacity = (roomData['capacity'] as num?)?.toInt() ?? 0;

        final activeSessionId = roomData['activeSessionId'] as String?;

        if (activeSessionId == sessionId) {
          transaction.update(roomRef, {
            'activeSessionId': null,
            'activeSessionTitle': null,
            'activeGroupId': null,
            'activeGroupName': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    for (final participantDoc in joinedParticipantDocs) {
      transaction.update(participantDoc.reference, {
        'status': SessionParticipantStatus.left.value,
        'leftAt': FieldValue.serverTimestamp(),
      });
    }

    if (roomRef != null &&
        roomCurrentOccupancy != null &&
        roomCapacity != null &&
        joinedParticipantCount > 0) {
      final newOccupancy = max(
        0,
        roomCurrentOccupancy - joinedParticipantCount,
      );

      transaction.update(roomRef, {
        'currentOccupancy': newOccupancy,
        'isFull': roomCapacity > 0 && newOccupancy >= roomCapacity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _getJoinedParticipantDocs(String sessionId) async {
    _validateSessionId(sessionId);

    final snapshot = await _participantsRef(
      sessionId,
    ).where('status', isEqualTo: SessionParticipantStatus.joined.value).get();

    return snapshot.docs;
  }

  /*
  session participation transactions
   */
  Future<void> joinSessionTransaction({
    required String sessionId,
    required String userId,
    required String displayName,
    required String email,
  }) async {
    _validateSessionId(sessionId);
    _validateUserId(userId);
    _validateDisplayName(displayName);
    _validateEmail(email);

    await _firestore.runTransaction((transaction) async {
      final sessionRef = _sessionRef(sessionId);
      final participantRef = _participantRef(
        sessionId: sessionId,
        userId: userId,
      );

      final sessionDoc = await transaction.get(sessionRef);

      if (!sessionDoc.exists) {
        throw Exception('Study session was not found.');
      }

      final sessionData = sessionDoc.data() ?? {};
      final groupId = sessionData['groupId'] as String? ?? '';
      final roomId = sessionData['roomId'] as String?;
      final status = sessionData['status'] as String? ?? '';
      final isActive = sessionData['isActive'] as bool? ?? true;
      final participantCount =
          (sessionData['participantCount'] as num?)?.toInt() ?? 0;

      if (!isActive) {
        throw Exception('This study session is no longer available.');
      }

      if (status != StudySessionStatus.active.value) {
        throw Exception('You can only join an active study session.');
      }

      if (groupId.isEmpty) {
        throw Exception('This study session is missing its group reference.');
      }

      final groupMemberRef = _groupMemberRef(groupId: groupId, userId: userId);
      final groupMemberDoc = await transaction.get(groupMemberRef);

      if (!groupMemberDoc.exists) {
        throw Exception('You must be a member of this group to join.');
      }

      final participantDoc = await transaction.get(participantRef);

      if (participantDoc.exists) {
        final participantData = participantDoc.data() ?? {};
        final participantStatus = participantData['status'] as String? ?? '';

        if (participantStatus == SessionParticipantStatus.joined.value) {
          throw Exception('You have already joined this session.');
        }
      }

      DocumentReference<Map<String, dynamic>>? roomRef;
      int? roomCurrentOccupancy;
      int? roomCapacity;

      if (roomId != null && roomId.trim().isNotEmpty) {
        roomRef = _roomRef(roomId);
        final roomDoc = await transaction.get(roomRef);

        if (!roomDoc.exists) {
          throw Exception('The selected study room was not found.');
        }

        final roomData = roomDoc.data() ?? {};
        final roomIsActive = roomData['isActive'] as bool? ?? true;
        final activeSessionId = roomData['activeSessionId'] as String?;
        final currentOccupancy =
            (roomData['currentOccupancy'] as num?)?.toInt() ?? 0;
        final capacity = (roomData['capacity'] as num?)?.toInt() ?? 0;

        if (!roomIsActive) {
          throw Exception('This study room is not currently available.');
        }

        if (activeSessionId != sessionId) {
          throw Exception(
            'This room is not currently active for this session.',
          );
        }

        if (capacity <= 0) {
          throw Exception('This study room has an invalid capacity.');
        }

        if (currentOccupancy >= capacity) {
          throw Exception('This study room is full.');
        }

        roomCurrentOccupancy = currentOccupancy;
        roomCapacity = capacity;
      }

      final participant = SessionParticipant(
        userId: userId,
        displayName: displayName,
        email: email,
        joinedAt: null,
        leftAt: null,
        status: SessionParticipantStatus.joined,
      );

      transaction.set(
        participantRef,
        participant.toJoinMap(),
        SetOptions(merge: true),
      );

      transaction.update(sessionRef, {
        'participantCount': participantCount + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (roomRef != null &&
          roomCurrentOccupancy != null &&
          roomCapacity != null) {
        final newOccupancy = roomCurrentOccupancy + 1;

        transaction.update(roomRef, {
          'currentOccupancy': newOccupancy,
          'isFull': newOccupancy >= roomCapacity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> leaveSessionTransaction({
    required String sessionId,
    required String userId,
  }) async {
    _validateSessionId(sessionId);
    _validateUserId(userId);

    await _firestore.runTransaction((transaction) async {
      final sessionRef = _sessionRef(sessionId);
      final participantRef = _participantRef(
        sessionId: sessionId,
        userId: userId,
      );

      final sessionDoc = await transaction.get(sessionRef);

      if (!sessionDoc.exists) {
        throw Exception('Study session was not found.');
      }

      final sessionData = sessionDoc.data() ?? {};
      final roomId = sessionData['roomId'] as String?;
      final participantCount =
          (sessionData['participantCount'] as num?)?.toInt() ?? 0;

      final participantDoc = await transaction.get(participantRef);

      if (!participantDoc.exists) {
        throw Exception('You have not joined this session.');
      }

      final participantData = participantDoc.data() ?? {};
      final participantStatus = participantData['status'] as String? ?? '';

      if (participantStatus != SessionParticipantStatus.joined.value) {
        throw Exception('You have already left this session.');
      }

      DocumentReference<Map<String, dynamic>>? roomRef;
      int? roomCurrentOccupancy;
      int? roomCapacity;

      if (roomId != null && roomId.trim().isNotEmpty) {
        roomRef = _roomRef(roomId);
        final roomDoc = await transaction.get(roomRef);

        if (roomDoc.exists) {
          final roomData = roomDoc.data() ?? {};
          roomCurrentOccupancy =
              (roomData['currentOccupancy'] as num?)?.toInt() ?? 0;
          roomCapacity = (roomData['capacity'] as num?)?.toInt() ?? 0;
        }
      }

      transaction.update(participantRef, {
        'status': SessionParticipantStatus.left.value,
        'leftAt': FieldValue.serverTimestamp(),
      });

      transaction.update(sessionRef, {
        'participantCount': max(0, participantCount - 1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (roomRef != null &&
          roomCurrentOccupancy != null &&
          roomCapacity != null) {
        final newOccupancy = max(0, roomCurrentOccupancy - 1);

        transaction.update(roomRef, {
          'currentOccupancy': newOccupancy,
          'isFull': roomCapacity > 0 && newOccupancy >= roomCapacity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /*
  validation helper methods
   */
  void _validateSessionId(String sessionId) {
    if (sessionId.trim().isEmpty) {
      throw Exception('Invalid study session.');
    }
  }

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

  void _validateDisplayName(String displayName) {
    if (displayName.trim().isEmpty) {
      throw Exception('Invalid display name.');
    }
  }

  void _validateEmail(String email) {
    if (email.trim().isEmpty) {
      throw Exception('Invalid email.');
    }
  }

  void _validateRoomId(String? roomId) {
    if (roomId == null || roomId.trim().isEmpty) {
      throw Exception('Invalid study room.');
    }
  }

  void _validateSessionTimes({
    required DateTime startsAt,
    required DateTime endsAt,
  }) {
    if (!startsAt.isBefore(endsAt)) {
      throw Exception('The start time must be before the end time.');
    }
  }

  void _validateStudySession(StudySession session) {
    _validateGroupId(session.groupId);
    _validateUserId(session.createdBy);
    _validateSessionTimes(startsAt: session.startsAt, endsAt: session.endsAt);

    if (session.title.trim().isEmpty) {
      throw Exception('Please enter a session title.');
    }

    if (session.participantCount < 0) {
      throw Exception('Participant count cannot be negative.');
    }
  }
}
