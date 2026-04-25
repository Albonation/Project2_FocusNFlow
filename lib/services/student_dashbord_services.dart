import 'package:focus_n_flow/models/task_model.dart';

class StudentDashbordServices {
  
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

}