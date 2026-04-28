import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/weekly_planner_service.dart';

class WeeklyPlannerView extends StatelessWidget {
  final List<Task> tasks;
  final WeeklyPlannerService service;

  const WeeklyPlannerView({
    super.key,
    required this.tasks,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final plan = service.generateWeeklyPlan(tasks);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: plan.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 10),

                ...entry.value.map((task) {
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}",
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.priorityScore.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Priority",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}