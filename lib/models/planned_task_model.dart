import 'package:cloud_firestore/cloud_firestore.dart';

class PlannedTask {
  final String taskId;
  final String title;
  final String courseId;
  final DateTime date;
  final int unitIndex;

  PlannedTask({
    required this.taskId,
    required this.title,
    required this.courseId,
    required this.date,
    required this.unitIndex,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'title': title,
      'course_id': courseId,
      'date': Timestamp.fromDate(date),
      'unit_index': unitIndex,
    };
  }

  
  factory PlannedTask.fromMap(Map<String, dynamic> map) {
    return PlannedTask(
      taskId: map['task_id'] ?? '',
      title: map['title'] ?? '',
      courseId: map['course_id'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      unitIndex: map['unit_index'] ?? 0,
    );
  }
}