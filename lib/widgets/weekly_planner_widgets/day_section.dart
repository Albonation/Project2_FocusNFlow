import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/task_card.dart';

class DaySection extends StatelessWidget {
  final DateTime date;
  final List<PlannedTask> tasks;

  const DaySection({
    super.key,
    required this.date,
    required this.tasks,
  });

  String _dayLabel(DateTime date) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final groupedByTask = <String, List<PlannedTask>>{};

    for (final t in tasks) {
      groupedByTask.putIfAbsent(t.taskId, () => []).add(t);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ExpansionTile(
        title: Text(
          "${_dayLabel(date)} (${date.month}/${date.day})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: groupedByTask.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("No tasks"),
                )
              ]
            : groupedByTask.entries.expand((entry) {
                final taskGroup = entry.value;

                return taskGroup.asMap().entries.map((e) {
                  return TaskCard(
                    task: e.value,
                    totalUnits: taskGroup.length,
                    dayIndex: e.key,
                  );
                });
              }).toList(),
      ),
    );
  }
}