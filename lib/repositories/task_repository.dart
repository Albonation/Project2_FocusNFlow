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
      return docRef.id; //
    } catch (e) {
      debugPrint('[TASK_REPO] Failed to add task: $e');
      rethrow;
    }
  }

  //read tasks, or stream tasks since using firestore
  //get all tasks for a specific user
  Stream<List<Task>> getTasksForUser(String userId) {
    throw UnimplementedError();
  }

  //get a specific task by id
  Future<Task?> getTaskById(String taskId) async {
    throw UnimplementedError();
  }

  //update task
  Future<void> updateTask(Task task) async {
    throw UnimplementedError();
  }

  //delete task
  Future<void> deleteTask(String taskId) async {
    throw UnimplementedError();
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
