//whether a task can be completed, completing a task, validating task data
//essentially the rules and logic for the task system
//importing necessarry packages
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskService {
  final TaskRepository taskRepository;

  TaskService({required this.taskRepository});

  //create a new task after validating all the necessary fields
  Future<TaskActionResult> createTask(Task task) async {
    if (task.id != null) {
      return failureResult(task, "New task should not already have an ID.");
    }

    final error = runValidation([
      () => validateUserId(task.userId),
      () => validateCourseId(task.courseId),
      () => validateTitle(task.title),
      () => validateEstimatedHours(task.estimatedHours),
      () => validateDeadline(task.deadline),
    ]);

    if (error != null) {
      return failureResult(task, error);
    }

    final now = DateTime.now(); //so they match
    final taskToCreate = task.copyWith(createdAt: now, updatedAt: now);

    final newTaskId = await taskRepository.addTask(taskToCreate);
    final createdTask = taskToCreate.copyWith(id: newTaskId);

    return successResult(createdTask, "Task created successfully.");
  }

  //complete a task if it can be completed and passes validation
  Future<TaskActionResult> completeTask(Task task) async {
    final error = runValidation([
      () => validateTaskId(task.id),
      () => validateUserId(task.userId),
      () => canCompleteTask(task),
    ]);

    if (error != null) {
      return failureResult(task, error);
    }

    await taskRepository.markTaskCompleted(
      userId: task.userId,
      taskId: task.id!,
    );

    final now = DateTime.now(); //so they match
    final updatedTask = task.copyWith(
      status: TaskStatus.completed,
      completedAt: now,
      updatedAt: now,
    );

    return successResult(updatedTask, 'Task marked as completed');
  }

  //update a task after passing validation checks
  Future<TaskActionResult> saveTaskChanges(Task task) async {
    final error = runValidation([
      () => validateTaskId(task.id),
      () => validateUserId(task.userId),
      () => validateCourseId(task.courseId),
      () => validateTitle(task.title),
      () => validateEstimatedHours(task.estimatedHours),
      () => validateDeadline(task.deadline),
    ]);

    if (error != null) {
      return failureResult(task, error);
    }

    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    await taskRepository.updateTask(updatedTask);

    return successResult(updatedTask, 'Task changes saved successfully');
  }

  //reopen a task if it is allowed to be and passes validation
  Future<TaskActionResult> reopenTask(Task task) async {
    final error = runValidation([
      () => validateTaskId(task.id),
      () => validateUserId(task.userId),
      () => canReopenTask(task),
    ]);

    if (error != null) {
      return failureResult(task, error);
    }

    await taskRepository.reopenTask(userId: task.userId, taskId: task.id!);

    final updatedTask = task.copyWith(
      status: TaskStatus.pending,
      clearCompletedAt: true,
      updatedAt: DateTime.now(),
    );

    return successResult(updatedTask, 'Task successfully reopened.');
  }

  //delete a task if it exists
  Future<TaskActionResult> deleteTask(Task task) async {
    final error = runValidation([
      () => validateTaskId(task.id),
      () => validateUserId(task.userId),
    ]);

    if (error != null) {
      return failureResult(task, error);
    }

    await taskRepository.deleteTask(userId: task.userId, taskId: task.id!);

    return successResult(task, 'Task successfully deleted.');
  }

  //helper methods to validate task data
  String? validateTaskId(String? taskId) {
    if (taskId == null || taskId.trim().isEmpty) {
      return 'Task ID is missing.';
    }
    return null;
  }

  String? validateUserId(String? userId) {
    if (userId == null || userId.trim().isEmpty) {
      return 'User ID is missing.';
    }
    return null;
  }

  String? validateCourseId(String? courseId) {
    if (courseId == null || courseId.trim().isEmpty) {
      return 'Course ID is missing.';
    }
    return null;
  }

  String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Title is missing.';
    }
    return null;
  }

  String? validateEstimatedHours(double? estimatedHours) {
    if (estimatedHours == null) {
      return 'Estimated hours must be provided.';
    }
    if (estimatedHours <= 0) {
      return 'Estimated hours should be greater than zero.';
    }
    return null;
  }

  String? validateDeadline(DateTime? deadline) {
    if (deadline == null) {
      return 'Deadline must be provided.';
    }
    if (deadline.isBefore(DateTime.now())) {
      return 'Deadline cannot be in the past.';
    }
    return null;
  }

  String? canCompleteTask(Task task) {
    if (task.isCompleted) {
      return 'Task is already completed.';
    }
    return null;
  }

  String? canReopenTask(Task task) {
    if (!task.isCompleted) {
      return 'Only completed tasks can be reopened.';
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
  TaskActionResult failureResult(Task task, String message) {
    return TaskActionResult(
      success: false,
      updatedTask: task,
      message: message,
    );
  }

  TaskActionResult successResult(Task task, String message) {
    return TaskActionResult(success: true, updatedTask: task, message: message);
  }
} //end of TaskService class

//a result model to cleanly pass the UI results from using task service
class TaskActionResult {
  final bool success;
  final Task? updatedTask;
  final String message;

  TaskActionResult({
    required this.success,
    this.updatedTask,
    required this.message,
  });
} //end of TaskActionResult class

//this is being saved for later use in the course layers
/*String? validateCourseId(String? courseId) {
    if (courseId == null || courseId.trim().isEmpty) {
      return 'Course ID is missing.';
    }
    final regex = RegExp(r'^[A-Z]{3,4}[0-9]{4}$');

    if (!regex.hasMatch(courseId)){
      return "Format must be like ECON1002 (3-4 letters + 4 numbers)";
    }

    return null;
  }*/
