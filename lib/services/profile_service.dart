import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/course_model.dart';
import 'package:focus_n_flow/services/course_service.dart';

class ProfileService {
  final CourseService courseService;

  ProfileService({
    required this.courseService,
  });

  String themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Course buildCourse({
    required String userId,
    required String courseCode,
    required String courseName,
    required double courseWeight,
  }) {
    return Course(
      userId: userId,
      courseCode: courseCode.trim(),
      courseName: courseName.trim(),
      courseWeight: courseWeight,
    );
  }

  Future<String> createCourse(Course course) async {
    final result = await courseService.createCourse(course);
    return result.message;
  }

  Future<String> deleteCourse(Course course) async {
    final result = await courseService.deleteCourse(course);
    return result.message;
  }
}