import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/session_goal_model.dart';

class SessionGoalRepository {
  final FirebaseFirestore _firestore;

  SessionGoalRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  //collection and doc references
  DocumentReference<Map<String, dynamic>> _sessionRef(String sessionId) {
    return _firestore.collection('study_sessions').doc(sessionId);
  }

  CollectionReference<Map<String, dynamic>> _goalsRef(String sessionId) {
    return _sessionRef(sessionId).collection('goals');
  }

  DocumentReference<Map<String, dynamic>> _goalRef({
    required String sessionId,
    required String goalId,
  }) {
    return _goalsRef(sessionId).doc(goalId);
  }

  //stream goals
  Stream<List<SessionGoal>> watchGoals(String sessionId) {
    _validateSessionId(sessionId);

    return _goalsRef(sessionId).orderBy('createdAt').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map(SessionGoal.fromFirestore).toList();
    });
  }

  //goal writes
  Future<String> addGoal({
    required String sessionId,
    required SessionGoal goal,
  }) async {
    _validateSessionId(sessionId);
    _validateGoal(goal);

    final docRef = await _goalsRef(sessionId).add(goal.toFirestore());
    return docRef.id;
  }

  Future<void> updateGoalText({
    required String sessionId,
    required String goalId,
    required String text,
  }) async {
    _validateSessionId(sessionId);
    _validateGoalId(goalId);
    _validateGoalText(text);

    await _firestore.runTransaction((transaction) async {
      final goalRef = _goalRef(sessionId: sessionId, goalId: goalId);
      final goalDoc = await transaction.get(goalRef);

      if (!goalDoc.exists) {
        throw Exception('Goal was not found.');
      }

      final goalData = goalDoc.data();

      if (goalData == null) {
        throw Exception('Goal data was missing.');
      }

      final isCompletedValue = goalData['isCompleted'];

      if (isCompletedValue is! bool) {
        throw Exception('Goal completion status was invalid.');
      }

      if (isCompletedValue) {
        throw Exception('Completed goals cannot be edited.');
      }

      transaction.update(goalRef, {
        'text': text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  //send isCompleted false to reopen a goal
  Future<void> setGoalCompletion({
    required String sessionId,
    required String goalId,
    required bool isCompleted,
    required String updatedBy,
    required String updatedByName,
  }) async {
    _validateSessionId(sessionId);
    _validateGoalId(goalId);
    _validateUserId(updatedBy);
    _validateDisplayName(updatedByName);

    await _firestore.runTransaction((transaction) async {
      final goalRef = _goalRef(sessionId: sessionId, goalId: goalId);
      final goalDoc = await transaction.get(goalRef);

      if (!goalDoc.exists) {
        throw Exception('Goal was not found.');
      }

      final goalData = goalDoc.data();

      if (goalData == null) {
        throw Exception('Goal data was missing.');
      }

      final isCompletedValue = goalData['isCompleted'];

      if (isCompletedValue is! bool) {
        throw Exception('Goal completion status was invalid.');
      }

      if (isCompletedValue == isCompleted) {
        throw Exception(
          isCompleted
              ? 'Someone already completed this goal.'
              : 'Someone already reopened this goal.',
        );
      }

      transaction.update(goalRef, {
        'isCompleted': isCompleted,
        'completedBy': isCompleted ? updatedBy : null,
        'completedByName': isCompleted ? updatedByName : null,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteGoal({
    required String sessionId,
    required String goalId,
  }) async {
    _validateSessionId(sessionId);
    _validateGoalId(goalId);

    await _firestore.runTransaction((transaction) async {
      final goalRef = _goalRef(sessionId: sessionId, goalId: goalId);
      final goalDoc = await transaction.get(goalRef);

      if (!goalDoc.exists) {
        throw Exception('Goal was not found.');
      }

      transaction.delete(goalRef);
    });
  }

  //validation helpers
  void _validateSessionId(String sessionId) {
    if (sessionId.trim().isEmpty) {
      throw Exception('Invalid study session.');
    }
  }

  void _validateGoalId(String goalId) {
    if (goalId.trim().isEmpty) {
      throw Exception('Invalid goal.');
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

  void _validateGoalText(String text) {
    if (text.trim().isEmpty) {
      throw Exception('Goal cannot be empty.');
    }

    if (text.trim().length > 120) {
      throw Exception('Goal must be 120 characters or less.');
    }
  }

  void _validateGoal(SessionGoal goal) {
    _validateGoalText(goal.text);
    _validateUserId(goal.createdBy);
    _validateDisplayName(goal.createdByName);
  }
}
