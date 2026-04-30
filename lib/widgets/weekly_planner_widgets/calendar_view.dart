import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:focus_n_flow/models/planning_model.dart';

class CalendarPlannerView extends StatefulWidget {
  final Stream<List<PlannedTask>> planStream;

  const CalendarPlannerView({
    super.key,
    required this.planStream,
  });

  @override
  State<CalendarPlannerView> createState() =>
      _CalendarPlannerViewState();
}

class _CalendarPlannerViewState extends State<CalendarPlannerView> {
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  List<PlannedTask> _tasks = [];

  List<PlannedTask> _getTasksForDay(DateTime day) {
    return _tasks.where((t) {
      return isSameDay(t.plannedDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlannedTask>>(
      stream: widget.planStream,
      builder: (context, snapshot) {

        if (snapshot.hasData) {
          _tasks = snapshot.data!;
        }

        return Column(
          children: [

            TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(selectedDay, day),

              eventLoader: _getTasksForDay,

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
                children: _getTasksForDay(selectedDay).map((planned) {

                  final task = planned.task;

                  return ListTile(
                    title: Text(task?.title ?? "Task"),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Study: ${planned.hoursForDay.toStringAsFixed(1)} hrs",
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Scheduled: ${DateFormat('MMM dd').format(planned.plannedDate)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
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
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}