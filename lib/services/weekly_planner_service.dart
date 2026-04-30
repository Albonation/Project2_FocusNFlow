import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/models/task_model.dart';

class WeeklyPlannerService {

  /// Convert tasks → initial schedule (ONLY used once)
  List<PlannedTask> createInitialPlan(List<Task> tasks) {
    final now = DateTime.now();

    final sorted = [...tasks]
      ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    final List<PlannedTask> result = [];

    DateTime cursor = DateTime(now.year, now.month, now.day, 9);

    for (final task in sorted) {
      double remaining = task.estimatedHours;

      while (remaining > 0) {
        final chunk = remaining > 2 ? 2.0 : remaining;

        result.add(
          PlannedTask(
            taskId: task.id!,
            hoursForDay: chunk,
            plannedDate: cursor,
          ),
        );

        remaining -= chunk;

        cursor = cursor.add(const Duration(hours: 2));

        if (cursor.hour >= 20) {
          cursor = DateTime(cursor.year, cursor.month, cursor.day + 1, 9);
        }
      }
    }

    return result;
  }

  /// Helper: filter by week
  List<PlannedTask> filterWeek(List<PlannedTask> tasks, DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 7));

    return tasks.where((t) {
      return t.plannedDate.isAfter(weekStart) &&
             t.plannedDate.isBefore(end);
    }).toList();
  }
}