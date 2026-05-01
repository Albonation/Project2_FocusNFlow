import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/task_model.dart';

class PlannerEngine {
  static const double maxHoursPerDay = 12.0;

  Plan generatePlan({
    required List<Task> tasks,
    required List<DateTime> days,
  }) {
    final normalizedDays = days.map(_normalize).toList();

    final sortedTasks = [...tasks]..sort((a, b) {
      final aScore = a.priorityScore / _daysLeft(a);
      final bScore = b.priorityScore / _daysLeft(b);
      return bScore.compareTo(aScore);
    });

    final Map<DateTime, List<PlannedTask>> schedule = {
      for (final d in normalizedDays) d: [],
    };

    for (final task in sortedTasks) {
      _distributeTask(task, normalizedDays, schedule);
    }

    return Plan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "Auto Generated Plan",
      createdAt: DateTime.now(),
      days: schedule,
    );
  }

  Plan autoGenerate(List<Task> tasks) {
    final days = List.generate(
      7,
      (i) => DateTime.now().add(Duration(days: i)),
    );

    return generatePlan(tasks: tasks, days: days);
  }

  // -------------------------
  // CORE DISTRIBUTION LOGIC
  // -------------------------
  void _distributeTask(
    Task task,
    List<DateTime> days,
    Map<DateTime, List<PlannedTask>> schedule,
  ) {
    final validDays =
        days.where((d) => !d.isAfter(task.deadline)).toList();

    if (validDays.isEmpty) return;

    double remaining = task.estimatedHours;

    for (final day in validDays) {
      if (remaining <= 0) break;

      final used = schedule[day]!.fold<double>(
        0,
        (sum, t) => sum + t.hours,
      );

      final free = maxHoursPerDay - used;

      if (free <= 0) continue;

      final allocated = remaining > free ? free : remaining;

      schedule[day]!.add(
        PlannedTask(
          taskId: task.id!,
          task: task,
          date: day,
          hours: allocated,
        ),
      );

      remaining -= allocated;
    }
  }

  // -------------------------
  // HELPERS
  // -------------------------
  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  double _daysLeft(Task t) =>
      (t.deadline.difference(DateTime.now()).inDays + 1)
          .clamp(1, 999)
          .toDouble();
}