//connect directly with firestore and get data from there
//all the CRUD operations for tasks will be here

//importing necessary packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/repositories/planner_firesto_repository.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');


  //add task nested in the users collection and return the generated document ID
  Future<String> addTask(Task task) async {
    try {
      DocumentReference<Map<String, dynamic>> docRef =
        await _tasksCollection(task.userId).add(task.toMap());
      debugPrint('[TASK_REPO] Added task: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to add task: $e');
      rethrow;
    }
  }

  //read tasks, or stream tasks since using firestore
  //get all tasks for a specific user
  Stream<List<Task>> getTasksForUser(String userId) {
      return _tasksCollection(userId)
          .orderBy('deadline')
          .snapshots()
          .map((snapshot) {
            debugPrint(
              '[TASK_REPO] Fetched ${snapshot.docs.length} tasks for user $userId',
            );
            return snapshot.docs
                .map((doc) => Task.fromMap(doc.data(), id: doc.id))
                .toList();
          });

  }

  //get a specific task using userId and taskId
  Future<Task?> getTaskById({
    required String userId,
    required String taskId,
    }) async {
    try {
      final doc = await _tasksCollection(userId).doc(taskId).get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('[TASK_REPO] Task not found: $taskId');
        return null;
      }

      debugPrint('[TASK_REPO] Fetched task: ${doc.id}');
      return Task.fromMap(doc.data()!, id: doc.id);
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to fetch task $taskId: $e');
      rethrow;
    }
  }

  //get tasks for a specific course for a user
  Stream<List<Task>> getTasksForCourse({
    required String userId,
    required String courseId,
    }) {
      return _tasksCollection(userId)
          .where('course_id', isEqualTo: courseId)
          .orderBy('deadline')
          .snapshots()
          .map((snapshot) {
            debugPrint(
              '[TASK_REPO] Fetched ${snapshot.docs.length} tasks for user $userId and course $courseId',
            );
            return snapshot.docs
                .map((doc) => Task.fromMap(doc.data(), id: doc.id))
                .toList();
          });
  }

  //update task
  Future<void> updateTask(Task task) async {
    if (task.id == null || task.id!.trim().isEmpty) {
      throw ArgumentError('Task must have a valid id before updateTask().');
    }

    try {
      await _tasksCollection(task.userId).doc(task.id).update(task.toMap());
      debugPrint('[TASK_REPO] Updated task: ${task.id}');
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to update task ${task.id}: $e');
      rethrow;
    }
  }

  //delete task
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      await _tasksCollection(userId).doc(taskId).delete();
      debugPrint('[TASK_REPO] Deleted task: $taskId');
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to delete task $taskId: $e');
      rethrow;
    }
  }

  //mark a task as completed
  Future<void> markTaskCompleted({
    required String userId,
    required String taskId,
  }) async {
    final now = Timestamp.now();

    await _tasksCollection(userId).doc(taskId).update({
      'status': TaskStatus.completed.value,
      'completed_at': now,
      'updated_at': now,
    });
  }

  //mark a task as in progress
  Future<void> markTaskInProgress({
    required String userId,
    required String taskId,
  }) async {
    final now = Timestamp.now();

    try {
      await _tasksCollection(userId).doc(taskId).update({
        'status': TaskStatus.inProgress.value,
        'updated_at': now,
      });
      debugPrint('[TASK_REPO] Marked task as in progress: $taskId');
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to mark task $taskId as in progress: $e');
      rethrow;
    }
  }

  //reopen a completed task
  Future<void> reopenTask({
    required String userId,
    required String taskId,
  }) async {
    final now = Timestamp.now();

    try {
      await _tasksCollection(userId).doc(taskId).update({
        'status': TaskStatus.pending.value,
        'completed_at': null,
        'updated_at': now,
      });
      debugPrint('[TASK_REPO] Reopened task: $taskId');
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to reopen task $taskId: $e');
      rethrow;
    }
  }

  //some maybe methods
  Future<Task?> getTaskByTaskId({
    required String userId,
    required String taskId,
  }) async {
    try {
      final doc = await _tasksCollection(userId)
          .doc(taskId)
          .get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('[TASK_REPO] Task not found: $taskId');
        return null;
      }

      debugPrint('[TASK_REPO] Fetched task: ${doc.id}');
      return Task.fromMap(doc.data()!, id: doc.id);
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to fetch task $taskId: $e');
      rethrow;
    }
  }
  
  /*

  //get tasks by status

  //get tasks by deadline

  //get tasks by estimated hours

  //maybe subtask stuffs

  */
} //end of class
