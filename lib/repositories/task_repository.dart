//connect directly with firestore and get data from there
//all the CRUD operations for tasks will be here

//importing necessary packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  //add task and return the generated document ID
  Future<String> addTask(Task task) async {
    try {
      DocumentReference<Map<String, dynamic>> docRef = await _tasksCollection
          .add(task.toMap());
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
    try {
      return _tasksCollection
          .where('user_id', isEqualTo: userId)
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
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to get tasks for user $userId: $e');
      rethrow;
    }
  }

  //get a specific task by id
  Future<Task?> getTaskById(String taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();

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

  //update task
  Future<void> updateTask(Task task) async {
    if (task.id == null || task.id!.trim().isEmpty) {
      throw ArgumentError('Task must have a valid id before updateTask().');
    }

    try {
      await _tasksCollection.doc(task.id).update(task.toMap());
      debugPrint('[TASK_REPO] Updated task: ${task.id}');
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to update task ${task.id}: $e');
      rethrow;
    }
  }

  //delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      debugPrint('[TASK_REPO] Deleted task: $taskId');
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to delete task $taskId: $e');
      rethrow;
    }
  }

  //some maybe methods
  /*

  //get tasks by status

  //get tasks by course id

  //get tasks by deadline

  //get tasks by estimated hours

  //maybe subtask stuffs

  */
} //end of class
