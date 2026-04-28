import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/weekly_planner_service.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPlannerView extends StatefulWidget {
  final List<Task> tasks;
  final WeeklyPlannerService service;

  const CalendarPlannerView({
    super.key,
    required this.tasks,
    required this.service,
  });

  @override
  State<CalendarPlannerView> createState() => _CalendarPlannerViewState();
}

class _CalendarPlannerViewState extends State<CalendarPlannerView> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  Widget build(BuildContext context) {
    final dayTasks = selectedDay == null
        ? widget.tasks
        : widget.service.filterTasksByDate(widget.tasks, selectedDay!);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: (selected, focused) {
            setState(() {
              selectedDay = selected;
              focusedDay = focused;
            });
          },
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView(
            children: dayTasks.map((task) {
              return ListTile(
                title: Text(task.title),
                subtitle: Text("Due: ${task.deadline}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(task.priorityScore.toStringAsFixed(1)),
                    const Text("Priority", style: TextStyle(fontSize: 10)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}