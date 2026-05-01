import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/planning_model.dart';
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

  Future<Plan> generateFromPrompt(String prompt, List<Task> tasks) async {
    final now = DateTime.now();

    final mode = _extractMode(prompt);

    int daySpan = 7;

    if (mode == "urgent") daySpan = 3;
    if (mode == "light") daySpan = 10;

    final days = List.generate(
      daySpan,
      (i) => now.add(Duration(days: i)),
    );

    final sortedTasks = [...tasks];

    // smarter sorting based on mode
    if (mode == "urgent") {
      sortedTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    } else if (mode == "light") {
      sortedTasks.shuffle();
    }

    final Map<DateTime, List<PlannedTask>> result = {
      for (final d in days) DateTime(d.year, d.month, d.day): []
    };

    int dayIndex = 0;

    for (final task in sortedTasks) {
      final day = days[dayIndex % days.length];

      result[DateTime(day.year, day.month, day.day)]!.add(
        PlannedTask(
          taskId: task.id!,
          task: task,
          date: day,
          hours: mode == "urgent" ? 3 : 2,
        ),
      );

      dayIndex++;
    }

    return Plan(
      id: now.millisecondsSinceEpoch.toString(),
      name: prompt.isEmpty ? "AI Plan" : prompt,
      createdAt: now,
      days: result,
    );
  }

  String _extractMode(String prompt) {
    final p = prompt.toLowerCase();

    if (p.contains("cram") || p.contains("urgent") || p.contains("asap")) {
      return "urgent";
    }

    if (p.contains("light") || p.contains("easy")) {
      return "light";
    }

    if (p.contains("exam") || p.contains("study")) {
      return "study";
    }

    return "normal";
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