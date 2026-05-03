import 'package:cloud_firestore/cloud_firestore.dart';

enum SharedTimerMode { focus, shortBreak, longBreak, idle }

extension SharedTimerModeX on SharedTimerMode {
  String get value {
    switch (this) {
      case SharedTimerMode.focus:
        return 'focus';
      case SharedTimerMode.shortBreak:
        return 'shortBreak';
      case SharedTimerMode.longBreak:
        return 'longBreak';
      case SharedTimerMode.idle:
        return 'idle';
    }
  }

  String get label {
    switch (this) {
      case SharedTimerMode.focus:
        return 'Focus';
      case SharedTimerMode.shortBreak:
        return 'Short Break';
      case SharedTimerMode.longBreak:
        return 'Long Break';
      case SharedTimerMode.idle:
        return 'Idle';
    }
  }

  int get defaultDurationSeconds {
    switch (this) {
      case SharedTimerMode.focus:
        return 25 * 60;
      case SharedTimerMode.shortBreak:
        return 5 * 60;
      case SharedTimerMode.longBreak:
        return 15 * 60;
      case SharedTimerMode.idle:
        return 25 * 60;
    }
  }

  static SharedTimerMode fromString(String? value) {
    switch (value) {
      case 'shortBreak':
        return SharedTimerMode.shortBreak;
      case 'longBreak':
        return SharedTimerMode.longBreak;
      case 'idle':
        return SharedTimerMode.idle;
      case 'focus':
      default:
        return SharedTimerMode.focus;
    }
  }
}

enum SharedTimerStatus { running, paused, stopped, completed }

extension SharedTimerStatusX on SharedTimerStatus {
  String get value {
    switch (this) {
      case SharedTimerStatus.running:
        return 'running';
      case SharedTimerStatus.paused:
        return 'paused';
      case SharedTimerStatus.stopped:
        return 'stopped';
      case SharedTimerStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case SharedTimerStatus.running:
        return 'Running';
      case SharedTimerStatus.paused:
        return 'Paused';
      case SharedTimerStatus.stopped:
        return 'Stopped';
      case SharedTimerStatus.completed:
        return 'Completed';
    }
  }

  static SharedTimerStatus fromString(String? value) {
    switch (value) {
      case 'running':
        return SharedTimerStatus.running;
      case 'paused':
        return SharedTimerStatus.paused;
      case 'completed':
        return SharedTimerStatus.completed;
      case 'stopped':
      default:
        return SharedTimerStatus.stopped;
    }
  }
}

class SharedTimerState {
  final String id;
  final SharedTimerMode mode;
  final SharedTimerStatus status;
  final int durationSeconds;
  final int remainingSeconds;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? updatedAt;
  final String updatedBy;
  final String updatedByName;

  const SharedTimerState({
    required this.id,
    required this.mode,
    required this.status,
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.startedAt,
    required this.pausedAt,
    required this.updatedAt,
    required this.updatedBy,
    required this.updatedByName,
  });

  factory SharedTimerState.initial({
    required String updatedBy,
    required String updatedByName,
    SharedTimerMode mode = SharedTimerMode.focus,
  }) {
    final durationSeconds = mode.defaultDurationSeconds;

    return SharedTimerState(
      id: 'state',
      mode: mode,
      status: SharedTimerStatus.stopped,
      durationSeconds: durationSeconds,
      remainingSeconds: durationSeconds,
      startedAt: null,
      pausedAt: null,
      updatedAt: null,
      updatedBy: updatedBy,
      updatedByName: updatedByName,
    );
  }

  factory SharedTimerState.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final mode = SharedTimerModeX.fromString(data['mode'] as String?);
    final durationSeconds =
        (data['durationSeconds'] as num?)?.toInt() ??
        mode.defaultDurationSeconds;

    return SharedTimerState(
      id: doc.id,
      mode: mode,
      status: SharedTimerStatusX.fromString(data['status'] as String?),
      durationSeconds: durationSeconds,
      remainingSeconds:
          (data['remainingSeconds'] as num?)?.toInt() ?? durationSeconds,
      startedAt: _dateTimeFromTimestamp(data['startedAt']),
      pausedAt: _dateTimeFromTimestamp(data['pausedAt']),
      updatedAt: _dateTimeFromTimestamp(data['updatedAt']),
      updatedBy: data['updatedBy'] as String? ?? '',
      updatedByName: data['updatedByName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mode': mode.value,
      'status': status.value,
      'durationSeconds': durationSeconds,
      'remainingSeconds': remainingSeconds,
      'startedAt': startedAt == null ? null : Timestamp.fromDate(startedAt!),
      'pausedAt': pausedAt == null ? null : Timestamp.fromDate(pausedAt!),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
    };
  }

  SharedTimerState copyWith({
    String? id,
    SharedTimerMode? mode,
    SharedTimerStatus? status,
    int? durationSeconds,
    int? remainingSeconds,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    DateTime? updatedAt,
    String? updatedBy,
    String? updatedByName,
  }) {
    return SharedTimerState(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      pausedAt: clearPausedAt ? null : pausedAt ?? this.pausedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedByName: updatedByName ?? this.updatedByName,
    );
  }

  int calculateDisplayRemainingSeconds(DateTime now) {
    if (status != SharedTimerStatus.running || startedAt == null) {
      return remainingSeconds;
    }

    final elapsedSeconds = now.difference(startedAt!).inSeconds;
    final calculatedRemaining = remainingSeconds - elapsedSeconds;

    if (calculatedRemaining <= 0) {
      return 0;
    }

    return calculatedRemaining;
  }

  bool get isRunning => status == SharedTimerStatus.running;

  bool get isPaused => status == SharedTimerStatus.paused;

  bool get isStopped => status == SharedTimerStatus.stopped;

  bool get isCompleted => status == SharedTimerStatus.completed;

  static DateTime? _dateTimeFromTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
