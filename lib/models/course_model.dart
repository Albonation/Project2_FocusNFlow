import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String? id;
  final String userId;
  final String courseCode;
  final String courseName;
  final double courseWeight;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    this.id,
    required this.userId,
    required this.courseCode,
    required this.courseName,
    required this.courseWeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'course_code': courseCode,
      'course_name': courseName,
      'course_weight': courseWeight,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map, {String? id}) {
    return Course(
      id: id ?? map['id'] as String?,
      userId: map['user_id'] as String,
      courseCode: map['course_code'] as String,
      courseName: map['course_name'] as String,
      courseWeight: (map['course_weight'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Course copyWith({
    String? id,
    String? userId,
    String? courseCode,
    String? courseName,
    double? courseWeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      courseWeight: courseWeight ?? this.courseWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName {
    if (courseName.trim().isEmpty) {
      return courseCode;
    }

    return '$courseCode - $courseName';
  }
}
