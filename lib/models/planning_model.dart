import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_n_flow/models/task_model.dart';

class PlannedTask {
  final Task task;
  final double hoursForDay;
  final DateTime plannedDate;

  PlannedTask({
    required this.task,
    required this.hoursForDay,
    required this.plannedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'task_id': task.id,
      'hours_for_day': hoursForDay,
      'planned_date': Timestamp.fromDate(plannedDate),
    };
  }

  factory PlannedTask.fromMap(
    Map<String, dynamic> map,
    Task task,
  ) {
    return PlannedTask(
      task: task,
      hoursForDay: (map['hours_for_day'] as num).toDouble(),
      plannedDate: (map['planned_date'] as Timestamp).toDate(),
    );
  }
}