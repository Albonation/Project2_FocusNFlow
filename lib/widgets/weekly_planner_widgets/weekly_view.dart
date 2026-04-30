import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/repositories/weekly_planner_repository.dart';

class WeeklyPlannerView extends StatefulWidget {
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

  @override
  State<WeeklyPlannerView> createState() => _WeeklyPlannerViewState();
}

class _WeeklyPlannerViewState extends State<WeeklyPlannerView> {
  List<PlannedTask> _localTasks = [];

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlannedTask>>(
      stream: widget.planStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          _localTasks = snapshot.data!;
        }

        final grouped = <DateTime, List<PlannedTask>>{};

        for (final t in _localTasks) {
          final day = _normalize(t.plannedDate);
          grouped.putIfAbsent(day, () => []);
          grouped[day]!.add(t);
        }

        final days = grouped.keys.toList()..sort();

        if (days.isEmpty) {
          return const Center(
            child: Text("No planned tasks yet."),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: days.map((day) {
            final tasks = grouped[day]!;

            return DragTarget<PlannedTask>(
              onAcceptWithDetails: (details) async {
                final draggedTask = details.data;

                // Prevent accidental rebuild conflicts
                final updated = _localTasks.map((t) {
                  if (t.taskId == draggedTask.taskId) {
                    return PlannedTask(
                      taskId: t.taskId,
                      task: t.task,
                      hoursForDay: t.hoursForDay,
                      plannedDate: day,
                    );
                  }
                  return t;
                }).toList();

                setState(() {
                  _localTasks = updated;
                });

                // persist change
                await widget.repository.movePlannedTask(
                  widget.userId,
                  widget.weekId,
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

                        ...tasks.map((task) {
                          final dragged = task;

                          return LongPressDraggable<PlannedTask>(
                            data: dragged,

                            feedback: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  dragged.task?.title ?? "Task",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildTaskTile(dragged),
                            ),

                            child: _buildTaskTile(dragged),
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

  Widget _buildTaskTile(PlannedTask task) {
    return ListTile(
      title: Text(task.task?.title ?? "Task"),

      subtitle: Text(
        "Study: ${task.hoursForDay.toStringAsFixed(1)} hrs",
      ),

      trailing: Text(
        task.task?.priorityScore.toStringAsFixed(1) ?? "-",
      ),
    );
  }
}