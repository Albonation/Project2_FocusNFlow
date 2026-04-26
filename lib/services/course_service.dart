import '../models/course_model.dart';
import '../repositories/course_repository.dart';

class CourseService {
  final CourseRepository courseRepository;

  CourseService({required this.courseRepository});

  //create a new course after validating all the necessary fields
  Future<CourseActionResult> createCourse(Course course) async {
    if (course.id != null && course.id!.trim().isNotEmpty) {
      return failureResult(course, 'New course should not already have an ID.');
    }

    final error = runValidation([
          () => validateUserId(course.userId),
          () => validateCourseCode(course.courseCode),
          () => validateCourseWeight(course.courseWeight),
    ]);

    if (error != null) {
      return failureResult(course, error);
    }

    final now = DateTime.now(); //so they match
    final normalizedCourse = course.copyWith(
      courseCode: normalizeCourseCode(course.courseCode),
      courseName: course.courseName.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final newCourseId = await courseRepository.addCourse(normalizedCourse);

    final createdCourse = normalizedCourse.copyWith(id: newCourseId);

    return successResult(createdCourse, 'Course created successfully.');
  }

  //update a course after passing validation checks
  Future<CourseActionResult> saveCourseChanges(Course course) async {
    final error = runValidation([
          () => validateCourseId(course.id),
          () => validateUserId(course.userId),
          () => validateCourseCode(course.courseCode),
          () => validateCourseWeight(course.courseWeight),
    ]);

    if (error != null) {
      return failureResult(course, error);
    }

    final updatedCourse = course.copyWith(
      courseCode: normalizeCourseCode(course.courseCode),
      courseName: course.courseName.trim(),
      updatedAt: DateTime.now(),
    );

    await courseRepository.updateCourse(updatedCourse);

    return successResult(updatedCourse, 'Course changes saved successfully.');
  }

  //delete a course if it exists
  Future<CourseActionResult> deleteCourse(Course course) async {
    final error = runValidation([
          () => validateCourseId(course.id),
          () => validateUserId(course.userId),
    ]);

    if (error != null) {
      return failureResult(course, error);
    }

    await courseRepository.deleteCourse(
      userId: course.userId,
      courseId: course.id!,
    );

    return successResult(course, 'Course deleted successfully.');
  }

  //normalize course code by removing whitespace and converting to uppercase
  String normalizeCourseCode(String courseCode) {
    return courseCode.replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  //helper methods to validate course data
  String? validateCourseId(String? courseId) {
    if (courseId == null || courseId.trim().isEmpty) {
      return 'Course ID is missing.';
    }
    return null;
  }

  String? validateUserId(String? userId) {
    if (userId == null || userId.trim().isEmpty) {
      return 'User ID is missing.';
    }
    return null;
  }

  String? validateCourseCode(String? courseCode) {
    if (courseCode == null || courseCode.trim().isEmpty) {
      return 'Course code is missing.';
    }

    final normalized = normalizeCourseCode(courseCode);

    final regex = RegExp(r'^[A-Z]{3,4}[0-9]{4}$');
    if (!regex.hasMatch(normalized)) {
      return 'Course code should look like CSC4360 or MATH3020.';
    }

    return null;
  }

  String? validateCourseWeight(double? courseWeight) {
    if (courseWeight == null) {
      return 'Course weight is required.';
    }

    if (courseWeight < 1 || courseWeight > 5) {
      return 'Course weight must be between 1 and 5.';
    }

    return null;
  }

  //helper method to run validation checks in order and return first error message found
  //or null if all pass
  String? runValidation(List<String? Function()> checks) {
    for (final check in checks) {
      final result = check();
      if (result != null) return result;
    }
    return null;
  }

  //helper methods to create consistent action results for the UI
  CourseActionResult failureResult(Course course, String message) {
    return CourseActionResult(
      success: false,
      updatedCourse: course,
      message: message,
    );
  }

  CourseActionResult successResult(Course course, String message) {
    return CourseActionResult(
      success: true,
      updatedCourse: course,
      message: message,
    );
  }
}//end of CourseService class

//a result model to cleanly pass the UI results from using course service
class CourseActionResult {
  final bool success;
  final Course? updatedCourse;
  final String message;

  CourseActionResult({
    required this.success,
    this.updatedCourse,
    required this.message,
  });
}//end of CourseActionResult class