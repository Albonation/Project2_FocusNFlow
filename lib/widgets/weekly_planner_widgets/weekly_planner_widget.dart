import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/weekly_planner_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class WeeklyPlannerWidget extends StatelessWidget {
  final String userId;
  final TaskRepository repository;
  final WeeklyPlannerService service;

  const WeeklyPlannerWidget({
    super.key,
    required this.userId,
    required this.repository,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: repository.getTasksForUser(userId),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("Add tasks to generate Weekly Plan"),
          );
        }

        final tasks = snapshot.data!;
        final plan = service.generateWeeklyPlan(tasks);

        return ListView(
          padding: AppSpacing.screen,
          children: plan.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: AppSpacing.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: context.text.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    AppSpacing.gapMd,

                    ...entry.value.map((task) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(task.title),
                        subtitle: Text(
                          "Due: ${task.deadline.toLocal()}",
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
      },
    );
  }
}