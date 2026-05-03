import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'task_card.dart';

class DaySection extends StatelessWidget {
  final DateTime date;
  final List<PlannedTask> tasks;
  final Map<String, Task> taskMap;

  const DaySection({
    super.key,
    required this.date,
    required this.tasks,
    required this.taskMap,
  });

  String _dayLabel(DateTime date) {
    const days = [
      "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ExpansionTile(
        title: Text(
          "${_dayLabel(date)} (${date.month}/${date.day})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: tasks.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("No tasks"),
                )
              ]
            : tasks.map((t) {
                final fullTask = taskMap[t.taskId];

                final totalUnits = tasks
                    .where((x) => x.taskId == t.taskId)
                    .length;

                return TaskCard(
                  task: t,
                  fullTask: fullTask,
                  totalUnits: totalUnits,
                );
              }).toList(),
      ),
    );
  }
}