import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/repositories/weekly_planner_repository.dart';

class CalendarPlannerView extends StatefulWidget {
  final String userId;
  final Stream<List<PlannedTask>> planStream;
  final WeeklyPlannerRepository repository;

  const CalendarPlannerView({
    super.key,
    required this.userId,
    required this.planStream,
    required this.repository,
  });

  @override
  State<CalendarPlannerView> createState() =>
      _CalendarPlannerViewState();
}

class _CalendarPlannerViewState
    extends State<CalendarPlannerView> {

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  List<PlannedTask> _tasks = [];

  List<PlannedTask> _tasksForDay(DateTime day) {
    return _tasks.where((t) =>
        isSameDay(t.plannedDate, day)).toList();
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

            //CALENDAR GRID (DROP TARGET)
            TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(selectedDay, day),

              eventLoader: _tasksForDay,

              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return DragTarget<PlannedTask>(
                    onAcceptWithDetails: (task) async {
                      await widget.repository.movePlannedTask(
                        userId: widget.userId,
                        taskId: task.taskId,
                        newDate: day,
                      );
                    },

                    builder: (context, candidate, rejected) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: candidate.isNotEmpty
                              ? Colors.blue.shade100
                              : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text('${day.day}'),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            //TASK LIST (DRAG SOURCE)
            Expanded(
              child: ListView(
                children: _tasksForDay(selectedDay).map((task) {

                  return LongPressDraggable<PlannedTask>(
                    data: task,

                    feedback: Material(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.blue,
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
                      child: _taskTile(task),
                    ),

                    child: _taskTile(task),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _taskTile(PlannedTask task) {
    final t = task.task;

    return ListTile(
      title: Text(t?.title ?? "Task"),

      subtitle: Text(
        "Study: ${task.hoursForDay.toStringAsFixed(1)} hrs",
      ),

      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t?.priorityScore.toStringAsFixed(1) ?? "-",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text("Priority", style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}