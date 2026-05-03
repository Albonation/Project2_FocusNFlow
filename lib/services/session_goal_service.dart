import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/session_goal_model.dart';
import 'package:focus_n_flow/repositories/session_goal_repository.dart';

class SessionGoalService {
  final SessionGoalRepository _repository;
  final FirebaseAuth _auth;

  SessionGoalService({SessionGoalRepository? repository, FirebaseAuth? auth})
    : _repository = repository ?? SessionGoalRepository(),
      _auth = auth ?? FirebaseAuth.instance;

  //stream goals
  Stream<List<SessionGoal>> watchGoals(String sessionId) {
    return _repository.watchGoals(sessionId);
  }

  //goal actions
  Future<SessionGoalActionResult> addGoal({
    required String sessionId,
    required String text,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'add a goal'),
      () => _validateSessionId(sessionId),
      () => _validateGoalText(text),
    ]);

    if (error != null) {
      return SessionGoalActionResult.failure(error);
    }

    try {
      final goal = SessionGoal(
        id: '',
        text: text.trim(),
        createdBy: user!.uid,
        createdByName: _resolveDisplayName(user),
        createdAt: null,
        updatedAt: null,
        isCompleted: false,
        completedBy: null,
        completedByName: null,
        completedAt: null,
      );

      final goalId = await _repository.addGoal(
        sessionId: sessionId.trim(),
        goal: goal,
      );

      return SessionGoalActionResult.success(
        message: 'Goal added.',
        goalId: goalId,
      );
    } catch (error) {
      return SessionGoalActionResult.failure(_cleanError(error));
    }
  }

  Future<SessionGoalActionResult> updateGoalText({
    required String sessionId,
    required String goalId,
    required String text,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'edit a goal'),
      () => _validateSessionId(sessionId),
      () => _validateGoalId(goalId),
      () => _validateGoalText(text),
    ]);

    if (error != null) {
      return SessionGoalActionResult.failure(error);
    }

    try {
      await _repository.updateGoalText(
        sessionId: sessionId.trim(),
        goalId: goalId.trim(),
        text: text.trim(),
      );

      return SessionGoalActionResult.success(
        message: 'Goal updated.',
        goalId: goalId,
      );
    } catch (error) {
      return SessionGoalActionResult.failure(_cleanError(error));
    }
  }

  Future<SessionGoalActionResult> setGoalCompletion({
    required String sessionId,
    required String goalId,
    required bool isCompleted,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'update a goal'),
      () => _validateSessionId(sessionId),
      () => _validateGoalId(goalId),
    ]);

    if (error != null) {
      return SessionGoalActionResult.failure(error);
    }

    try {
      await _repository.setGoalCompletion(
        sessionId: sessionId.trim(),
        goalId: goalId.trim(),
        isCompleted: isCompleted,
        updatedBy: user!.uid,
        updatedByName: _resolveDisplayName(user),
      );

      return SessionGoalActionResult.success(
        message: isCompleted ? 'Goal completed.' : 'Goal reopened.',
        goalId: goalId,
      );
    } catch (error) {
      return SessionGoalActionResult.failure(_cleanError(error));
    }
  }

  Future<SessionGoalActionResult> deleteGoal({
    required String sessionId,
    required String goalId,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'delete a goal'),
      () => _validateSessionId(sessionId),
      () => _validateGoalId(goalId),
    ]);

    if (error != null) {
      return SessionGoalActionResult.failure(error);
    }

    try {
      await _repository.deleteGoal(
        sessionId: sessionId.trim(),
        goalId: goalId.trim(),
      );

      return SessionGoalActionResult.success(
        message: 'Goal deleted.',
        goalId: goalId,
      );
    } catch (error) {
      return SessionGoalActionResult.failure(_cleanError(error));
    }
  }

  //validation helpers
  User? get _currentUser => _auth.currentUser;

  String? _validateSignedIn(User? user, String action) {
    if (user == null) {
      return 'You must be signed in to $action.';
    }

    return null;
  }

  String? _validateSessionId(String? sessionId) {
    if (sessionId == null || sessionId.trim().isEmpty) {
      return 'Invalid study session.';
    }

    return null;
  }

  String? _validateGoalId(String? goalId) {
    if (goalId == null || goalId.trim().isEmpty) {
      return 'Invalid goal.';
    }

    return null;
  }

  String? _validateGoalText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Goal cannot be empty.';
    }

    if (text.trim().length > 120) {
      return 'Goal must be 120 characters or less.';
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

  //formatting helpers
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

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

//result object for UI messages
class SessionGoalActionResult {
  final bool success;
  final String message;
  final String? goalId;

  const SessionGoalActionResult({
    required this.success,
    required this.message,
    this.goalId,
  });

  factory SessionGoalActionResult.success({
    required String message,
    String? goalId,
  }) {
    return SessionGoalActionResult(
      success: true,
      message: message,
      goalId: goalId,
    );
  }

  factory SessionGoalActionResult.failure(String message) {
    return SessionGoalActionResult(success: false, message: message);
  }
}
