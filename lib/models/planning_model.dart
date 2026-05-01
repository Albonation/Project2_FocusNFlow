import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/task_model.dart';

class PlannedTask {
  final String taskId;
  final Task? task;
  final double hoursForDay;
  final DateTime plannedDate;

  final DateTime? startTime;
  final DateTime? endTime;

  final bool isLocked;

  PlannedTask({
    required this.taskId,
    this.task,
    required this.hoursForDay,
    required this.plannedDate,
    this.startTime,
    this.endTime,
    this.isLocked = false,
  });

  /// Firestore write
  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'hours_for_day': hoursForDay,
      'planned_date': Timestamp.fromDate(plannedDate),
    };
  }

  /// Firestore read
  factory PlannedTask.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return PlannedTask(
      taskId: docId,
      hoursForDay: (map['hours_for_day'] as num).toDouble(),
      plannedDate: (map['planned_date'] as Timestamp).toDate(),
    );
  }

  /// Attach task for UI rendering
  PlannedTask copyWithTask(Task task) {
    return PlannedTask(
      taskId: taskId,
      task: task,
      hoursForDay: hoursForDay,
      plannedDate: plannedDate,
    );
  }
}