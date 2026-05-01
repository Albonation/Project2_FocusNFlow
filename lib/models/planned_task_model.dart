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
    DateTime? date,
    double? hours,
    bool? isLocked,
  }) {
    return PlannedTask(
      taskId: taskId,
      task: task,
      date: date ?? this.date,
      hours: hours ?? this.hours,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}