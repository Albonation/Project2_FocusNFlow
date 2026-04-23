import 'package:focus_n_flow/models/task_model.dart';

class StudentDashbordServices {
  
  double calculateTaskScore(Task task) {

    final now = DateTime.now();

    // 1. Deadline urgency (closer = higher score)
    final daysLeft = task.deadline.difference(now).inDays;
    final safeDaysLeft = daysLeft < 0 ? 0 : daysLeft;

    final deadlineScore = (1 / (safeDaysLeft + 1)) * 10;

    // 2. Effort (harder = higher priority)
    final effortScore = task.effort * 2;

    // 3. Course weight (more important class = higher priority)
    final weightScore = task.courseWeight * 3;

    return deadlineScore + effortScore + weightScore;
  }

  double getProgress(Task task) {
    final score = calculateTaskScore(task);

    // adjust max based on your system
    return (score / 30).clamp(0.0, 1.0);
  }

}