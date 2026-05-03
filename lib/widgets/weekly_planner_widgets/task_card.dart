import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';

class TaskCard extends StatelessWidget {
  final PlannedTask task;
  final int totalUnits;
  final int dayIndex;

  const TaskCard({
    super.key,
    required this.task,
    required this.totalUnits,
    required this.dayIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.book),
        title: Text("Session ${dayIndex + 1} of $totalUnits"),
        subtitle: Text(
          "Task Name: ${task.title}\n"
          "Date: ${task.date.month}/${task.date.day}",
        ),
      ),
    );
  }
}