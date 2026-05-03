import 'package:cloud_firestore/cloud_firestore.dart';

class PlannedTask {
  final String id;
  final String taskId;
  final DateTime date;
  final int unitIndex;
  final DateTime weekStart;

  PlannedTask({
    required this.id,
    required this.taskId,
    required this.date,
    required this.unitIndex,
    required this.weekStart,
  });

  factory PlannedTask.fromMap(String id, Map<String, dynamic> data) {
    return PlannedTask(
      id: id,
      taskId: data['task_id'] as String,
      date: (data['date'] as Timestamp).toDate(),
      unitIndex: (data['unit_index'] as num).toInt(),
      weekStart: (data['week_start'] as Timestamp).toDate(),
    );
  }

 DateTime _normalize(DateTime d) =>
    DateTime(d.year, d.month, d.day);

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'date': Timestamp.fromDate(_normalize(date)),   
      'unit_index': unitIndex,
      'week_start': Timestamp.fromDate(_normalize(weekStart)),
    };
  }

  PlannedTask copyWith({
    String? id,
    String? taskId,
    DateTime? date,
    int? unitIndex,
    DateTime? weekStart,
  }) {
    return PlannedTask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
      unitIndex: unitIndex ?? this.unitIndex,
      weekStart: weekStart ?? this.weekStart,
    );
  }
}