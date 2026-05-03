import 'package:cloud_firestore/cloud_firestore.dart';

class PlannedTask {
  final String taskId;
  final String title;
  final String courseId;
  final DateTime date;
  final int unitIndex;
  final bool isCompleted;

  PlannedTask({
    required this.taskId,
    required this.title,
    required this.courseId,
    required this.date,
    required this.unitIndex,
    this.isCompleted = false
  });

  PlannedTask copyWith({
    String? taskId,
    String? title,
    String? courseId,
    DateTime? date,
    int? unitIndex,
    bool? isCompleted,
  }) {
    return PlannedTask(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      date: date ?? this.date,
      unitIndex: unitIndex ?? this.unitIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'title': title,
      'course_id': courseId,
      'date': Timestamp.fromDate(date),
      'unit_index': unitIndex,
      'is_completed': isCompleted,
    };
  }

  
  factory PlannedTask.fromMap(Map<String, dynamic> map) {
    return PlannedTask(
      taskId: map['task_id'] ?? '',
      title: map['title'] ?? '',
      courseId: map['course_id'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      unitIndex: map['unit_index'] ?? 0,
      isCompleted: map['is_completed'] ?? false,
    );
  }
}