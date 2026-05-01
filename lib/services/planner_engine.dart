import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/task_model.dart';

class PlannerEngine {
  static const maxHoursPerDay = 12.0;

  Map<DateTime, List<PlannedTask>> generate({
    required List<Task> tasks,
    required List<DateTime> days,
  }) {
    final map = {
      for (final d in days) d: <PlannedTask>[],
    };

    final sorted = [...tasks]..sort((a, b) {
      final aScore = a.priorityScore / _daysLeft(a);
      final bScore = b.priorityScore / _daysLeft(b);
      return bScore.compareTo(aScore);
    });

    for (final task in sorted) {
      final parts = _splitTask(task, days);

      for (final part in parts) {
        _place(map, part);
      }
    }

    _merge(map);

    return map;
  }

  double _daysLeft(Task t) =>
      (t.deadline.difference(DateTime.now()).inDays + 1).clamp(1, 999).toDouble();

  List<PlannedTask> _splitTask(Task task, List<DateTime> days) {
    final validDays =
        days.where((d) => !d.isAfter(task.deadline)).toList();

    if (validDays.isEmpty) return [];

    final perDay = task.estimatedHours / validDays.length;

    return validDays.map((d) {
      return PlannedTask(
        taskId: task.id!,
        task: task,
        date: d,
        hours: perDay,
      );
    }).toList();
  }

  void _place(
    Map<DateTime, List<PlannedTask>> map,
    PlannedTask task,
  ) {
    final day = task.date;

    final current = map[day]!;

    final used = current.fold<double>(
      0,
      (sum, t) => sum + t.hours,
    );

    final free = maxHoursPerDay - used;

    if (free <= 0) return;

    final hours = task.hours > free ? free : task.hours;

    current.add(task.copyWith(hours: hours));
  }

  void _merge(Map<DateTime, List<PlannedTask>> map) {
    for (final day in map.keys) {
      final grouped = <String, PlannedTask>{};

      for (final t in map[day]!) {
        if (grouped.containsKey(t.taskId)) {
          grouped[t.taskId] = grouped[t.taskId]!.copyWith(
            hours: grouped[t.taskId]!.hours + t.hours,
          );
        } else {
          grouped[t.taskId] = t;
        }
      }

      map[day] = grouped.values.toList();
    }
  }
}