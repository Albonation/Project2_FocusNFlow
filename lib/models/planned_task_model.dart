import 'package:focus_n_flow/models/task_model.dart';

class PlannedTask {
  final String taskId;
  final Task task;
  final DateTime date;
  final double hours;
  final bool isLocked;

  PlannedTask({
    required this.taskId,
    required this.task,
    required this.date,
    required this.hours,
    this.isLocked = false,
  });

  PlannedTask copyWith({
    String? taskId,
    Task? task,
    DateTime? date,
    double? hours,
    bool? isLocked,
  }) {
    return PlannedTask(
      taskId: taskId ?? this.taskId,
      task: task ?? this.task,
      date: date ?? this.date,
      hours: hours ?? this.hours,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlannedTask &&
        other.taskId == taskId &&
        other.date == date;
  }

  @override
  int get hashCode => taskId.hashCode ^ date.hashCode;
}