import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/models/task_model.dart';

class WeeklyPlannerService {
  List<PlannedTask> generateSchedule(List<Task> tasks) {
    final now = DateTime.now();

    final sorted = [...tasks]
      ..sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    final List<PlannedTask> schedule = [];

    DateTime cursor = DateTime(now.year, now.month, now.day, 9); // 9AM start

    for (final task in sorted) {
      double remaining = task.estimatedHours;

      while (remaining > 0) {
        final chunk = remaining > 2 ? 2 : remaining; // max 2hr blocks

        schedule.add(
          PlannedTask(
            taskId: task.id!,
            hoursForDay: chunk,
            plannedDate: cursor,
          ),
        );

        remaining -= chunk;

        cursor = cursor.add(const Duration(hours: 2));

        // move to next day after 8pm
        if (cursor.hour >= 20) {
          cursor = DateTime(cursor.year, cursor.month, cursor.day + 1, 9);
        }
      }
    }

    return schedule;
  }

  List<Task> filterTasksByDate(List<Task> tasks, DateTime date){
    return tasks.where((t)=>
      t.deadline.year == date.year &&
      t.deadline.month == date.month &&
      t.deadline.day == date.day
    ).toList();
  }
}