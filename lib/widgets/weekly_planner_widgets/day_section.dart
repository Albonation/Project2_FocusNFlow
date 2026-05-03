import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/task_card.dart';

class DaySection extends StatelessWidget {
  final DateTime date;
  final List<PlannedTask> tasks;
  final void Function(PlannedTask task, bool newValue)? onToggle;

  const DaySection({
    super.key,
    required this.date,
    required this.tasks,
    this.onToggle,
  });

  String _dayLabel(DateTime date) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

  String _formatDateId(DateTime date) {
    return date.toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    final groupedByTask = <String, List<PlannedTask>>{};

    for (final t in tasks) {
      groupedByTask.putIfAbsent(t.taskId, () => []).add(t);
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final dateId = _formatDateId(date);

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
                  final task = e.value;

                  return TaskCard(
                    task: task,
                    totalUnits: taskGroup.length,
                    dayIndex: e.key,
                    onToggle: (PlannedTask task, bool newValue) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('weekly_plans')
                          .doc(dateId)
                          .collection('planned_tasks')
                          .doc(task.id)
                          .update({
                            'is_completed': newValue,
                          });

                      // optional: notify parent if needed
                      onToggle?.call(task, newValue);
                    },
                  );
                });
              }).toList(),
      ),
    );
  }
}