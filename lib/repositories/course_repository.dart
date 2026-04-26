import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _coursesCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('courses');

  //add course nested in the users collection and return the generated document ID
  Future<String> addCourse(Course course) async {
    try {
      final docRef = await _coursesCollection(course.userId).add(course.toMap());

      debugPrint('[COURSE_REPO] Added course: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[COURSE_REPO] Failed to add course: $e');
      rethrow;
    }
  }

  //read courses, or stream courses since using firestore
  //get all courses for a specific user
  Stream<List<Course>> getCoursesForUser(String userId) {
    return _coursesCollection(userId)
        .orderBy('course_code')
        .snapshots()
        .map((snapshot) {
      debugPrint(
        '[COURSE_REPO] Fetched ${snapshot.docs.length} courses for user $userId',
      );

      return snapshot.docs
          .map((doc) => Course.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  //get a specific course using userId and courseId
  Future<Course?> getCourseById({
    required String userId,
    required String courseId,
  }) async {
    try {
      final doc = await _coursesCollection(userId).doc(courseId).get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('[COURSE_REPO] Course not found: $courseId');
        return null;
      }

      debugPrint('[COURSE_REPO] Fetched course: ${doc.id}');
      return Course.fromMap(doc.data()!, id: doc.id);
    } catch (e) {
      debugPrint('[COURSE_REPO] Failed to fetch course $courseId: $e');
      rethrow;
    }
  }

  //update course
  Future<void> updateCourse(Course course) async {
    if (course.id == null || course.id!.trim().isEmpty) {
      throw ArgumentError('Course must have a valid id before updateCourse().');
    }

    try {
      await _coursesCollection(course.userId)
          .doc(course.id)
          .update(course.toMap());

      debugPrint('[COURSE_REPO] Updated course: ${course.id}');
    } catch (e) {
      debugPrint('[COURSE_REPO] Failed to update course ${course.id}: $e');
      rethrow;
    }
  }

  //delete course
  Future<void> deleteCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      await _coursesCollection(userId).doc(courseId).delete();

      debugPrint('[COURSE_REPO] Deleted course: $courseId');
    } catch (e) {
      debugPrint('[COURSE_REPO] Failed to delete course $courseId: $e');
      rethrow;
    }
  }
}