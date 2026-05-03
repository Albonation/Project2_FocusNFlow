import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/shared_timer_state_model.dart';
import 'package:focus_n_flow/repositories/shared_timer_repository.dart';

class SharedTimerService {
  final SharedTimerRepository _repository;
  final FirebaseAuth _auth;

  SharedTimerService({SharedTimerRepository? repository, FirebaseAuth? auth})
    : _repository = repository ?? SharedTimerRepository(),
      _auth = auth ?? FirebaseAuth.instance;


  //streams and fetchers
  Stream<SharedTimerState?> watchTimerState(String sessionId) {
    return _repository.watchTimerState(sessionId);
  }

  Future<SharedTimerState?> getTimerState(String sessionId) {
    return _repository.getTimerState(sessionId);
  }


  //timer actions
  Future<SharedTimerActionResult> initializeTimerIfMissing(
    String sessionId,
  ) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'initialize the shared timer'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return SharedTimerActionResult.failure(error);
    }

    try {
      final initialState = SharedTimerState.initial(
        updatedBy: user!.uid,
        updatedByName: _resolveDisplayName(user),
      );

      await _repository.initializeTimerIfMissing(
        sessionId: sessionId.trim(),
        timerState: initialState,
      );

      return SharedTimerActionResult.success(message: 'Shared timer is ready.');
    } catch (error) {
      return SharedTimerActionResult.failure(_cleanError(error));
    }
  }

  Future<SharedTimerActionResult> startTimer(String sessionId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'start the shared timer'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return SharedTimerActionResult.failure(error);
    }

    try {
      await _repository.startTimer(
        sessionId: sessionId.trim(),
        updatedBy: user!.uid,
        updatedByName: _resolveDisplayName(user),
      );

      return SharedTimerActionResult.success(message: 'Shared timer started.');
    } catch (error) {
      return SharedTimerActionResult.failure(_cleanError(error));
    }
  }

  Future<SharedTimerActionResult> pauseTimer({
    required String sessionId,
    required int remainingSeconds,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'pause the shared timer'),
      () => _validateSessionId(sessionId),
      () => _validateRemainingSeconds(remainingSeconds),
    ]);

    if (error != null) {
      return SharedTimerActionResult.failure(error);
    }

    try {
      await _repository.pauseTimer(
        sessionId: sessionId.trim(),
        remainingSeconds: remainingSeconds,
        updatedBy: user!.uid,
        updatedByName: _resolveDisplayName(user),
      );

      return SharedTimerActionResult.success(message: 'Shared timer paused.');
    } catch (error) {
      return SharedTimerActionResult.failure(_cleanError(error));
    }
  }

  Future<SharedTimerActionResult> resetTimer(String sessionId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'reset the shared timer'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return SharedTimerActionResult.failure(error);
    }

    try {
      await _repository.resetTimer(
        sessionId: sessionId.trim(),
        updatedBy: user!.uid,
        updatedByName: _resolveDisplayName(user),
      );

      return SharedTimerActionResult.success(message: 'Shared timer reset.');
    } catch (error) {
      return SharedTimerActionResult.failure(_cleanError(error));
    }
  }

  Future<SharedTimerActionResult> completeTimer(String sessionId) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'complete the shared timer'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return SharedTimerActionResult.failure(error);
    }

    try {
      await _repository.completeTimer(
        sessionId: sessionId.trim(),
        updatedBy: user!.uid,
        updatedByName: _resolveDisplayName(user),
      );

      return SharedTimerActionResult.success(
        message: 'Shared timer completed.',
      );
    } catch (error) {
      return SharedTimerActionResult.failure(_cleanError(error));
    }
  }

  Future<SharedTimerActionResult> changeMode({
    required String sessionId,
    required SharedTimerMode mode,
  }) async {
    final user = _currentUser;

    final error = _runValidation([
      () => _validateSignedIn(user, 'change the shared timer mode'),
      () => _validateSessionId(sessionId),
    ]);

    if (error != null) {
      return SharedTimerActionResult.failure(error);
    }

    try {
      await _repository.changeMode(
        sessionId: sessionId.trim(),
        mode: mode,
        updatedBy: user!.uid,
        updatedByName: _resolveDisplayName(user),
      );

      return SharedTimerActionResult.success(
        message: 'Timer mode changed to ${mode.label}.',
      );
    } catch (error) {
      return SharedTimerActionResult.failure(_cleanError(error));
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

  String? _validateRemainingSeconds(int remainingSeconds) {
    if (remainingSeconds < 0) {
      return 'Remaining seconds cannot be negative.';
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
class SharedTimerActionResult {
  final bool success;
  final String message;

  const SharedTimerActionResult({required this.success, required this.message});

  factory SharedTimerActionResult.success({required String message}) {
    return SharedTimerActionResult(success: true, message: message);
  }

  factory SharedTimerActionResult.failure(String message) {
    return SharedTimerActionResult(success: false, message: message);
  }
}
