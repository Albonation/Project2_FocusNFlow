import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/models/task_model.dart';

class WeeklyPlannerService {

  Map<String, List<PlannedTask>> generateWeeklyPlan(List<Task> tasks) {
    final now = DateTime.now();

    final days = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day + i),
    );

    final plan = <String, List<PlannedTask>>{};
    final usedHours = <String, double>{};
    const double dailyCapacity = 4.0;

    for (final day in days) {
      final label = "${day.month}/${day.day}";
      plan[label] = [];
      usedHours[label] = 0;
    }

    final activeTasks = tasks
        .where((t) => !t.isCompleted && !t.isOverdue)
        .toList();

    activeTasks.sort((a, b) {
      final deadlineCompare = a.deadline.compareTo(b.deadline);
      if (deadlineCompare != 0) return deadlineCompare;
      return b.priorityScore.compareTo(a.priorityScore);
    });

    for (final task in activeTasks) {
      double remainingHours = task.estimatedHours;

      final slots = days.length;

      final hoursPerDay = remainingHours / slots;

      for (int i = 0; i < slots; i++) {
        final day = days[i];
        final label = "${day.month}/${day.day}";

        final current = usedHours[label] ?? 0;

        if (remainingHours <= 0) break;

        if (current + hoursPerDay <= dailyCapacity) {
          plan[label]!.add(
            PlannedTask(
              task: task,
              hoursForDay: hoursPerDay,
              plannedDate: day,
            ),
          );

          usedHours[label] = current + hoursPerDay;
          remainingHours -= hoursPerDay;
        }
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