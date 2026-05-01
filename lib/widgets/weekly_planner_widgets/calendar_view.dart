import 'package:flutter/material.dart';
import 'package:focus_n_flow/services/planner_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:focus_n_flow/models/planning_model.dart';

class CalendarPlannerView extends StatefulWidget {
  final PlannerController controller;
  final String userId;

  const CalendarPlannerView({
    super.key,
    required this.controller,
    required this.userId,
  });

  @override
  State<CalendarPlannerView> createState() =>
      _CalendarPlannerViewState();
}

class _CalendarPlannerViewState extends State<CalendarPlannerView> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //CALENDAR GRID
        TableCalendar<PlannedTask>(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030),
          focusedDay: focusedDay,

          selectedDayPredicate: (day) =>
              isSameDay(selectedDay, day),

          eventLoader: (day) =>
              widget.controller.tasksForDay(day),

          onDaySelected: (selected, focused) {
            setState(() {
              selectedDay = selected;
              focusedDay = focused;
            });
          },

          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) {
              final tasks = widget.controller.tasksForDay(day);

              return DragTarget<PlannedTask>(
                onAcceptWithDetails: (details) async {
                  final task = details.data;
                  
                  await widget.controller.moveTask(
                    task,
                    day,
                  );
                },

                builder: (context, candidate, rejected) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: candidate.isNotEmpty
                          ? Colors.blue.shade100
                          : tasks.isNotEmpty
                              ? Colors.grey.shade200
                              : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        //SELECTED DAY TASKS
        Expanded(
          child: Builder(
            builder: (_) {
              final dayTasks =
                  widget.controller.tasksForDay(selectedDay);

              if (dayTasks.isEmpty) {
                return const Center(
                  child: Text("No tasks scheduled for this day"),
                );
              }

              return ListView.builder(
                itemCount: dayTasks.length,
                itemBuilder: (context, index) {
                  final task = dayTasks[index];

                  return LongPressDraggable<PlannedTask>(
                    data: task,

                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
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
                      opacity: 0.4,
                      child: _tile(task),
                    ),

                    child: _tile(task),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tile(PlannedTask task) {
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