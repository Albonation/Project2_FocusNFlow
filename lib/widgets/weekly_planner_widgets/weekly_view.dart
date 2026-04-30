import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/repositories/weekly_planner_repository.dart';

class WeeklyPlannerView extends StatelessWidget {
  final String userId;
  final String weekId;
  final WeeklyPlannerRepository repository;
  final Stream<List<PlannedTask>> planStream;

  const WeeklyPlannerView({
    super.key,
    required this.userId,
    required this.weekId,
    required this.repository,
    required this.planStream,
  });

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlannedTask>>(
      stream: planStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data!;

        final grouped = <DateTime, List<PlannedTask>>{};

        for (final t in tasks) {
          final day = _normalize(t.plannedDate);
          grouped.putIfAbsent(day, () => []);
          grouped[day]!.add(t);
        }

        final days = grouped.keys.toList()..sort();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: days.map((day) {

            final dayTasks = grouped[day]!;

            return DragTarget<PlannedTask>(
              onAccept: (draggedTask) async {

                await repository.moveTask(
                  userId,
                  weekId,
                  draggedTask.taskId,
                  day,
                );
              },

              builder: (context, candidate, rejected) {
                return Card(
                  color: candidate.isNotEmpty
                      ? Colors.blue.shade50
                      : null,
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

                        ...dayTasks.map((task) {

                          return LongPressDraggable<PlannedTask>(
                            data: task,
                            feedback: Material(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.blue,
                                child: Text(
                                  task.task?.title ?? "Task",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),

                            child: ListTile(
                              title: Text(task.task?.title ?? "Task"),

                              subtitle: Text(
                                "Study: ${task.hoursForDay.toStringAsFixed(1)} hrs",
                              ),

                              trailing: Text(
                                task.task?.priorityScore.toStringAsFixed(1) ?? "-",
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}