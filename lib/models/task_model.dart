import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { pending, inProgress, completed }

extension TaskStatusExtension on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
    }
  }

  static TaskStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        throw ArgumentError('Invalid task status: $value');
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

enum ImportanceLevel { low, normal, high }

extension ImportanceLevelExtension on ImportanceLevel {
  String get value {
    switch (this) {
      case ImportanceLevel.low:
        return 'low';
      case ImportanceLevel.normal:
        return 'normal';
      case ImportanceLevel.high:
        return 'high';
    }
  }

  static ImportanceLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return ImportanceLevel.low;
      case 'normal':
        return ImportanceLevel.normal;
      case 'high':
        return ImportanceLevel.high;
      default:
        throw ArgumentError('Invalid importance level: $value');
    }
  }

  String get label {
    switch (this) {
      case ImportanceLevel.low:
        return 'Low';
      case ImportanceLevel.normal:
        return 'Normal';
      case ImportanceLevel.high:
        return 'High';
    }
  }
}

class Task {
  final String? id;
  final String userId;
  final String courseId;
  final String title;
  final String description;
  final DateTime deadline;
  final double estimatedHours;
  final TaskStatus status;
  final ImportanceLevel manualImportance;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.userId,
    required this.courseId,
    required this.title,
    required this.deadline,
    required this.estimatedHours,
    this.description = '',
    this.status = TaskStatus.pending,
    this.manualImportance = ImportanceLevel.normal,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'estimated_hours': estimatedHours,
      'status': status.value,
      'manual_importance': manualImportance.value,
      'completed_at': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, {String? id}) {
    return Task(
      id: id ?? map['id'] as String?,
      userId: map['user_id'] as String,
      courseId: map['course_id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      deadline: (map['deadline'] as Timestamp).toDate(),
      estimatedHours: (map['estimated_hours'] as num).toDouble(),
      status: TaskStatusExtension.fromString(
        (map['status'] as String?) ?? 'pending',
      ),
      manualImportance: ImportanceLevelExtension.fromString(
        (map['manual_importance'] as String?) ?? 'normal',
      ),
      completedAt: map['completed_at'] != null
          ? (map['completed_at'] as Timestamp).toDate()
          : null,
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Task copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? title,
    String? description,
    DateTime? deadline,
    double? estimatedHours,
    TaskStatus? status,
    ImportanceLevel? manualImportance,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      status: status ?? this.status,
      manualImportance: manualImportance ?? this.manualImportance,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get priorityScore {
    final now = DateTime.now();

    final daysLeft = deadline.difference(now).inDays;
    final urgencyScore = daysLeft <= 0
        ? 100
        : (30 - daysLeft).clamp(0, 30).toDouble();

    final effortScore = estimatedHours * 2;

    final importanceScore = switch (manualImportance) {
      ImportanceLevel.low => 10,
      ImportanceLevel.normal => 20,
      ImportanceLevel.high => 30,
    };

    return urgencyScore + effortScore + importanceScore;
  }

  bool get isCompleted => status == TaskStatus.completed;

  bool get isOverdue => !isCompleted && deadline.isBefore(DateTime.now());
}
