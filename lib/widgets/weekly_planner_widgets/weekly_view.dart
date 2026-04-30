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
    final overdueTasks = tasks.where((t) => t.isOverdue).toList();
    final activeTasks = tasks.where((t) => !t.isOverdue).toList();
    final plan = service.generateWeeklyPlan(activeTasks);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        //OVERDUE SECTION
        if (overdueTasks.isNotEmpty)
          Card(
            color: Colors.red.shade50,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overdue Tasks",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  ...overdueTasks.map((task) => ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        "Was due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        //WEEKLY PLAN
        ...plan.entries.map((entry) {
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

                  ...entry.value.map((planned) {
                    final task = planned.task;

                    return ListTile(
                      title: Text(task.title),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Due: ${DateFormat('MMM dd, yyyy').format(task.deadline)}",
                          ),

                          const SizedBox(height: 4),

                          if (task.description.isNotEmpty) ...[
                            Text(
                              task.description,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                          ],

                          Text(
                            "Study: ${planned.hoursForDay.toStringAsFixed(1)} hrs",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
        }),
      ],
    );
  }
}