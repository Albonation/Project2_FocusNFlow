import 'package:focus_n_flow/models/task_model.dart';

class StudentDashboardService {
  //method to count tasks completed today
  int countCompletedToday(List<Task> tasks) {
    final now = DateTime.now();

    return tasks.where((task) {
      final completedAt = task.completedAt;
      if (completedAt == null) return false;

      return completedAt.year == now.year &&
          completedAt.month == now.month &&
          completedAt.day == now.day;
    }).length;
  }

  //methods to return counts for various task statuses
  int countPendingTasks(List<Task> tasks) {
    return tasks.where((task) => task.status == TaskStatus.pending).length;
  }

  int countInProgressTasks(List<Task> tasks) {
    return tasks.where((task) => task.status == TaskStatus.inProgress).length;
  }

  int countCompletedTasks(List<Task> tasks) {
    return tasks.where((task) => task.isCompleted).length;
  }

  int countOverdueTasks(List<Task> tasks) {
    return tasks.where((task) => task.isOverdue).length;
  }

  List<Task> getTopPriorityTasks(List<Task> tasks, {int limit = 3}) {
    final activeTasks = tasks.where((task) => !task.isCompleted).toList();

    activeTasks.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    return activeTasks.take(limit).toList();
  }

  Task? getNextDueTask(List<Task> tasks) {
    final activeTasks = tasks.where((task) => !task.isCompleted).toList();

    if (activeTasks.isEmpty) return null;

    activeTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    return activeTasks.first;
  }
}

//saving this for reference because it seems this logic was moved to task model
/*
class StudentDashboardService {
  
  double calculateTaskScore(Task task) {

    final now = DateTime.now();

    // 1. Deadline urgency (closer = higher score)
    final daysLeft = task.deadline.difference(now).inDays;
    final safeDaysLeft = daysLeft < 0 ? 0 : daysLeft;

    final deadlineScore = (1 / (safeDaysLeft + 1)) * 10;

    // 2. Effort (harder = higher priority)
    final effortScore = task.estimatedHours * 2;

    // 3. Manual importance level
    double importanceScore = 0;

    switch (task.manualImportance){
      case ImportanceLevel.low:
        importanceScore = 5;
        break;
      case ImportanceLevel.normal:
        importanceScore = 10;
        break;
      case ImportanceLevel.high:
        importanceScore = 15;
        break;
    }

    return deadlineScore + effortScore + importanceScore;
  }

  double getProgress(Task task) {
    final score = calculateTaskScore(task);

    // adjust max based on system
    return (score / 30).clamp(0.0, 1.0);
  }
}*/
