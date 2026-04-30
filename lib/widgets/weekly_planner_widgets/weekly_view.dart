import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/repositories/weekly_planner_repository.dart';
import 'package:intl/intl.dart';

class WeeklyPlannerView extends StatelessWidget {
  final String userId;
  final String weekId;
  final WeeklyPlannerRepository repository;

  const WeeklyPlannerView({
    super.key,
    required this.userId,
    required this.weekId,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlannedTask>>(
      stream: repository.getPlan(userId, weekId),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final plannedTasks = snapshot.data!;

        final grouped = _groupByDate(plannedTasks);

        final sortedKeys = grouped.keys.toList()
          ..sort();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: sortedKeys.map((day) {

            final tasks = grouped[day]!;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      DateFormat('EEE, MMM d').format(day),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 10),

                    ...tasks.map((planned) {
                      final task = planned.task;

                      return ListTile(
                        title: Text(task?.title ?? "Unknown"),

                        subtitle: Text(
                          "Study: ${planned.hoursForDay.toStringAsFixed(1)} hrs",
                        ),

                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              task?.priorityScore.toStringAsFixed(1) ?? "-",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text("Priority", style: TextStyle(fontSize: 10)),
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

  Map<DateTime, List<PlannedTask>> _groupByDate(List<PlannedTask> items) {
    final map = <DateTime, List<PlannedTask>>{};

    for (final item in items) {
      final day = DateTime(
        item.plannedDate.year,
        item.plannedDate.month,
        item.plannedDate.day,
      );

      map.putIfAbsent(day, () => []);
      map[day]!.add(item);
    }

    return map;
  }
}