import 'package:flutter/material.dart';
import 'package:focus_n_flow/services/planner_service.dart';
import 'package:intl/intl.dart';
import 'package:focus_n_flow/models/planning_model.dart';

class WeeklyPlannerView extends StatefulWidget {
  final PlannerController controller;

  const WeeklyPlannerView({
    super.key,
    required this.controller,
  });

  @override
  State<WeeklyPlannerView> createState() =>
      _WeeklyPlannerViewState();
}

class _WeeklyPlannerViewState extends State<WeeklyPlannerView> {

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final grouped = widget.controller.groupedWeek();

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
                final task = details.data;

                await widget.controller.moveTask(
                  task.taskId,
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEE, MMM d')
                              .format(day),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge,
                        ),

                        const SizedBox(height: 10),

                        ...tasks.map((task) {
                          return LongPressDraggable<PlannedTask>(
                            data: task,

                            feedback: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding:
                                    const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.circular(
                                          8),
                                ),
                                child: Text(
                                  task.task?.title ?? "Task",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child:
                                  _buildTaskTile(task),
                            ),

                            child: _buildTaskTile(task),
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