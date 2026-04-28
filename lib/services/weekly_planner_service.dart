import 'package:focus_n_flow/models/task_model.dart';

class WeeklyPlannerService {

  Map<String, List<Task>> generateWeeklyPlan(List<Task> tasks) {
    final now = DateTime.now();

    final upcomingDays = List.generate(
      7,
      (index) => DateTime(
        now.year,
        now.month,
        now.day + index,
      ),
    );

    final activeTasks = tasks.where((task) {
      return !task.isCompleted &&
          !task.isOverdue;
    }).toList();

    activeTasks.sort((a, b) {
      final deadlineCompare =
          a.deadline.compareTo(b.deadline);

      if (deadlineCompare != 0) {
        return deadlineCompare;
      }

      return b.priorityScore.compareTo(a.priorityScore);
    });

    final plan = <String, List<Task>>{};

    for (final day in upcomingDays) {
      final dayLabel = "${day.month}/${day.day}";
      plan[dayLabel] = [];
    }

    for (final task in activeTasks) {
      final cleanDeadline = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );

      final availableDays = upcomingDays.where((day) {
        final cleanDay = DateTime(
          day.year,
          day.month,
          day.day,
        );

        return !cleanDay.isAfter(cleanDeadline);
      }).toList();

      if (availableDays.isEmpty) continue;

      final hoursPerDay =
          (task.estimatedHours / availableDays.length);

      for (final day in availableDays) {
        final dayLabel = "${day.month}/${day.day}";

        final splitTask = task.copyWith(
          description:
              "${task.description}\nRecommended Study Time: ${hoursPerDay.toStringAsFixed(1)} hrs",
        );

        plan[dayLabel]!.add(splitTask);
      }
    }

    return plan;
  }

  List<Task> filterTasksByDate(List<Task> tasks, DateTime date){
    return tasks.where((t)=>
      t.deadline.year == date.year &&
      t.deadline.month == date.month &&
      t.deadline.day == date.day
    ).toList();
  }
}