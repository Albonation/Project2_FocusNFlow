//whether a task can be completed, completing a task, validating task data
//essentially the rules and logic for the task system
//importing necessarry packages
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskService {
  final TaskRepository taskRepository;

  TaskService({required this.taskRepository});

  //create a new task after validating all the necessary fields
  Future<TaskActionResult> createTask(Task task) async {
    final userIdError = validateUserId(task.userId);
    if (userIdError != null) {
      return failureResult(task, userIdError);
    }

    final courseIdError = validateCourseId(task.courseId);
    if (courseIdError != null) {
      return failureResult(task, courseIdError);
    }

    final titleError = validateTitle(task.title);
    if (titleError != null) {
      return failureResult(task, titleError);
    }

    final estimatedHoursError = validateEstimatedHours(task.estimatedHours);
    if (estimatedHoursError != null) {
      return failureResult(task, estimatedHoursError);
    }

    final deadlineError = validateDeadline(task.deadline);
    if (deadlineError != null) {
      return failureResult(task, deadlineError);
    }

    final newTaskId = await taskRepository.addTask(task);

    final createdTask = task.copyWith(
      id: newTaskId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return successResult(createdTask, 'Task created successfully.');
  }

  //complete a task if it can be completed and passes validation
  Future<TaskActionResult> completeTask(Task task) async {
    final taskIdError = validateTaskId(task.id);
    if (taskIdError != null) {
      return failureResult(task, taskIdError);
    }

    final canCompleteError = canCompleteTask(task);
    if (canCompleteError != null) {
      return failureResult(task, canCompleteError);
    }

    await taskRepository.markTaskCompleted(task.id!);

    final updatedTask = task.copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return successResult(updatedTask, 'Task marked as completed');
  }

  //update a task after passing validation checks
  Future<TaskActionResult> saveTaskChanges(Task task) async {
    final userIdError = validateUserId(task.userId);
    if (userIdError != null) {
      return failureResult(task, userIdError);
    }

    final courseIdError = validateCourseId(task.courseId);
    if (courseIdError != null) {
      return failureResult(task, courseIdError);
    }

    final titleError = validateTitle(task.title);
    if (titleError != null) {
      return failureResult(task, titleError);
    }

    final estimatedHoursError = validateEstimatedHours(task.estimatedHours);
    if (estimatedHoursError != null) {
      return failureResult(task, estimatedHoursError);
    }

    final deadlineError = validateDeadline(task.deadline);
    if (deadlineError != null) {
      return failureResult(task, deadlineError);
    }

    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await taskRepository.updateTask(updatedTask);

    return successResult(updatedTask, 'Task changes successfully saved.');
  }

  //reopen a task if it is allowed to be and passes validation
  Future<TaskActionResult> reopenTask(Task task) async {
    final taskIdError = validateTaskId(task.id);
    if (taskIdError != null) {
      return failureResult(task, taskIdError);
    }

    final canReopenError = canReopenTask(task);
    if (canReopenError != null) {
      return failureResult(task, canReopenError);
    }

    await taskRepository.reopenTask(task.id!);

    final updatedTask = task.copyWith(
      status: TaskStatus.pending,
      clearCompletedAt: true,
      updatedAt: DateTime.now(),
    );

    return successResult(updatedTask, 'Task successfully reopened.');
  }

  //delete a task if it exists
  Future<TaskActionResult> deleteTask(Task task) async {
    final taskIdError = validateTaskId(task.id);
    if (taskIdError != null) {
      return failureResult(task, taskIdError);
    }

    await taskRepository.deleteTask(task.id!);

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

  //helper methods to create consistent action results for the UI
  TaskActionResult failureResult(Task task, String message) {
    return TaskActionResult(success: false, updatedTask: task, message: message);
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
