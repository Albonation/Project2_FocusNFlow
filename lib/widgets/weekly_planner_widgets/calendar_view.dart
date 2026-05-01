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
              DropdownButton<String>(
                value: plan.id,
                items: controller.savedPlans.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) {
                    controller.loadPlan(id);
                  }
                },
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  controller.savePlan(plan.name);
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
                      title: Text(task.taskId),
                      subtitle: Text("${task.hours}h"),
                      trailing: const Icon(Icons.drag_handle),
                      onTap: () {
                        // future drag/edit
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
}