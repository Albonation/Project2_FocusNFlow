import 'package:cloud_firestore/cloud_firestore.dart';

class PlannedTask {
  /// Firestore document ID (PRIMARY KEY)
  final String id;

  /// Logical task grouping ID (NOT Firestore doc id)
  final String taskId;

  final String title;
  final String courseId;
  final DateTime date;
  final int unitIndex;
  final bool isCompleted;

  PlannedTask({
    required this.id,
    required this.taskId,
    required this.title,
    required this.courseId,
    required this.date,
    required this.unitIndex,
    this.isCompleted = false,
  });

  /// Safe copyWith for state updates
  PlannedTask copyWith({
    String? id,
    String? taskId,
    String? title,
    String? courseId,
    DateTime? date,
    int? unitIndex,
    bool? isCompleted,
  }) {
    return PlannedTask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      date: date ?? this.date,
      unitIndex: unitIndex ?? this.unitIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Firestore serialization
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

  /// Firestore deserialization (ROBUST VERSION)
  factory PlannedTask.fromMap(Map<String, dynamic> map, String docId) {
    final rawDate = map['date'];

    DateTime parsedDate;

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return PlannedTask(
      id: docId, // ALWAYS Firestore doc ID
      taskId: map['task_id'] ?? '',
      title: map['title'] ?? '',
      courseId: map['course_id'] ?? '',
      date: parsedDate,
      unitIndex: map['unit_index'] ?? 0,
      isCompleted: map['is_completed'] ?? false,
    );
  }

  /// Optional: useful for debugging
  @override
  String toString() {
    return 'PlannedTask(id: $id, taskId: $taskId, title: $title, isCompleted: $isCompleted)';
  }
}