import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/shared_timer_state_model.dart';

class SharedTimerRepository {
  final FirebaseFirestore _firestore;

  SharedTimerRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;


  //collection and document references
  DocumentReference<Map<String, dynamic>> _sessionRef(String sessionId) {
    return _firestore.collection('study_sessions').doc(sessionId);
  }

  CollectionReference<Map<String, dynamic>> _sharedTimerRef(String sessionId) {
    return _sessionRef(sessionId).collection('shared_timer');
  }

  DocumentReference<Map<String, dynamic>> _timerStateRef(String sessionId) {
    return _sharedTimerRef(sessionId).doc('state');
  }


  //streams and fetchers
  Stream<SharedTimerState?> watchTimerState(String sessionId) {
    _validateSessionId(sessionId);

    return _timerStateRef(sessionId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SharedTimerState.fromFirestore(doc);
    });
  }

  Future<SharedTimerState?> getTimerState(String sessionId) async {
    _validateSessionId(sessionId);

    final doc = await _timerStateRef(sessionId).get();

    if (!doc.exists) return null;

    return SharedTimerState.fromFirestore(doc);
  }


  //timer state writes
  Future<void> initializeTimerIfMissing({
    required String sessionId,
    required SharedTimerState timerState,
  }) async {
    _validateSessionId(sessionId);
    _validateTimerState(timerState);

    final timerRef = _timerStateRef(sessionId);
    final doc = await timerRef.get();

    if (doc.exists) {
      return;
    }

    await timerRef.set(timerState.toFirestore());
  }

  Future<void> startTimer({
    required String sessionId,
    required String updatedBy,
    required String updatedByName,
  }) async {
    _validateSessionId(sessionId);
    _validateUserId(updatedBy);
    _validateDisplayName(updatedByName);

    await _firestore.runTransaction((transaction) async {
      final timerRef = _timerStateRef(sessionId);
      final timerDoc = await transaction.get(timerRef);

      if (!timerDoc.exists) {
        throw Exception('Shared timer has not been initialized.');
      }

      final currentState = SharedTimerState.fromFirestore(timerDoc);

      if (currentState.status == SharedTimerStatus.running) {
        throw Exception('The shared timer is already running.');
      }

      final remainingSeconds = currentState.remainingSeconds <= 0
          ? currentState.durationSeconds
          : currentState.remainingSeconds;

      transaction.update(timerRef, {
        'status': SharedTimerStatus.running.value,
        'remainingSeconds': remainingSeconds,
        'startedAt': FieldValue.serverTimestamp(),
        'pausedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': updatedBy,
        'updatedByName': updatedByName,
      });
    });
  }

  Future<void> pauseTimer({
    required String sessionId,
    required int remainingSeconds,
    required String updatedBy,
    required String updatedByName,
  }) async {
    _validateSessionId(sessionId);
    _validateRemainingSeconds(remainingSeconds);
    _validateUserId(updatedBy);
    _validateDisplayName(updatedByName);

    await _timerStateRef(sessionId).update({
      'status': SharedTimerStatus.paused.value,
      'remainingSeconds': remainingSeconds,
      'pausedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
    });
  }

  Future<void> resetTimer({
    required String sessionId,
    required String updatedBy,
    required String updatedByName,
  }) async {
    _validateSessionId(sessionId);
    _validateUserId(updatedBy);
    _validateDisplayName(updatedByName);

    await _firestore.runTransaction((transaction) async {
      final timerRef = _timerStateRef(sessionId);
      final timerDoc = await transaction.get(timerRef);

      if (!timerDoc.exists) {
        throw Exception('Shared timer has not been initialized.');
      }

      final currentState = SharedTimerState.fromFirestore(timerDoc);

      transaction.update(timerRef, {
        'status': SharedTimerStatus.stopped.value,
        'remainingSeconds': currentState.durationSeconds,
        'startedAt': null,
        'pausedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': updatedBy,
        'updatedByName': updatedByName,
      });
    });
  }

  Future<void> completeTimer({
    required String sessionId,
    required String updatedBy,
    required String updatedByName,
  }) async {
    _validateSessionId(sessionId);
    _validateUserId(updatedBy);
    _validateDisplayName(updatedByName);

    await _timerStateRef(sessionId).update({
      'status': SharedTimerStatus.completed.value,
      'remainingSeconds': 0,
      'startedAt': null,
      'pausedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
    });
  }

  Future<void> changeMode({
    required String sessionId,
    required SharedTimerMode mode,
    required String updatedBy,
    required String updatedByName,
  }) async {
    _validateSessionId(sessionId);
    _validateUserId(updatedBy);
    _validateDisplayName(updatedByName);

    final durationSeconds = mode.defaultDurationSeconds;

    await _timerStateRef(sessionId).set({
      'mode': mode.value,
      'status': SharedTimerStatus.stopped.value,
      'durationSeconds': durationSeconds,
      'remainingSeconds': durationSeconds,
      'startedAt': null,
      'pausedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
    }, SetOptions(merge: true));
  }


  //validation helpers
  void _validateSessionId(String sessionId) {
    if (sessionId.trim().isEmpty) {
      throw Exception('Invalid study session.');
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

  void _validateRemainingSeconds(int remainingSeconds) {
    if (remainingSeconds < 0) {
      throw Exception('Remaining seconds cannot be negative.');
    }
  }

  void _validateTimerState(SharedTimerState timerState) {
    if (timerState.durationSeconds <= 0) {
      throw Exception('Timer duration must be greater than zero.');
    }

    if (timerState.remainingSeconds < 0) {
      throw Exception('Remaining seconds cannot be negative.');
    }

    if (timerState.remainingSeconds > timerState.durationSeconds) {
      throw Exception('Remaining seconds cannot exceed timer duration.');
    }

    _validateUserId(timerState.updatedBy);
    _validateDisplayName(timerState.updatedByName);
  }
}
