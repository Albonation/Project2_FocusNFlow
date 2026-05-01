import 'package:flutter/material.dart';
import 'package:focus_n_flow/services/planner_service.dart';

class CalendarView extends StatelessWidget {
  final PlannerController controller;

  const CalendarView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final plan = controller.currentPlan;

    if (plan == null) {
      return const Center(
        child: Text("No plan selected"),
      );
    }

    final days = plan.days.keys.toList()..sort();

    return Column(
      children: [
        // TOP BAR
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                plan.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  controller.savePlanToFirestore();
                },
                child: const Text("Save Plan"),
              ),
            ],
          ),
        ),

        const Divider(),

        // CALENDAR BODY
        Expanded(
          child: ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final tasks = plan.days[day] ?? [];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(
                    "${day.year}-${day.month}-${day.day}",
                  ),
                  children: tasks.map((task) {
                    return ListTile(
                      title: Text(task.task.title),
                      subtitle: Text("${task.hours}h allocated"),
                      trailing: const Icon(Icons.drag_handle),

                      onTap: () {
                        _showTaskDetails(context, controller, task);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // -------------------------
  // TASK DETAIL POPUP
  // -------------------------
  void _showTaskDetails(
    BuildContext context,
    PlannerController controller,
    task,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(task.task.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Task ID: ${task.taskId}"),
              Text("Hours: ${task.hours}"),
              Text("Date: ${task.date}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.removeAllocation(task);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}