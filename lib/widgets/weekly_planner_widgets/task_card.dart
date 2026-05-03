import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';

class TaskCard extends StatelessWidget {
  final PlannedTask task;
  final int totalUnits;
  final int dayIndex;

  final void Function(PlannedTask task, bool newValue)? onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.totalUnits,
    required this.dayIndex,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;

    return Card(
      color: isCompleted ? Colors.green.withValues(alpha: 0.2) : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          final newValue = !isCompleted;

          debugPrint('[TASK CARD] tapped: ${task.id}');
          debugPrint('[TASK CARD] current: $isCompleted -> new: $newValue');

          onToggle?.call(task, newValue);
        },
        child: ListTile(
          leading: Icon(
            isCompleted ? Icons.check_circle : Icons.book,
            color: isCompleted ? Colors.green : null,
          ),
          title: Text(
            "Session ${dayIndex + 1} of $totalUnits",
            style: TextStyle(
              decoration:
                  isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            "Task Name: ${task.title}\n"
            "Date: ${task.date.month}/${task.date.day}",
          ),
        ),
      ),
    );
  }
}