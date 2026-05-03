import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/task_model.dart';

class PlannerEngine {
  static const int maxUnitsPerDay = 12;

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  List<DateTime> _generateWeek(DateTime weekStart) {
    final start = _normalize(weekStart);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  List<PlannedTask> generateWeeklyPlan({
    required List<Task> tasks,
    required DateTime weekStart,
  }) {
    final week = _generateWeek(weekStart);

    final plan = <PlannedTask>[];

    for (final task in tasks) {
    
      if (task.status == TaskStatus.completed) continue;

      final total = task.estimatedHours.ceil();

      for (int i = 0; i < total; i++) {
        final day = week[i % 7];

        plan.add(
          PlannedTask(
            taskId: task.id!,
            title: task.title,
            courseId: task.courseId,
            date: day,
            unitIndex: i,
          ),
        );
      }
    }

    return plan;
  }
}