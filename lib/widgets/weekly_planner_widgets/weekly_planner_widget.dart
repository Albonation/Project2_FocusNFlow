import 'package:flutter/material.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/weekly_planner_service.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/calendar_view.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/weekly_view.dart';

class WeeklyPlannerWidget extends StatefulWidget {
  final String userId;
  final TaskRepository repository;
  final WeeklyPlannerService service;

  const WeeklyPlannerWidget({
    super.key,
    required this.userId,
    required this.repository,
    required this.service,
  });

  @override
  State<WeeklyPlannerWidget> createState() => _WeeklyPlannerSectionState();
}

class _WeeklyPlannerSectionState extends State<WeeklyPlannerWidget> {
  bool showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text("Weekly")),
              ButtonSegment(value: true, label: Text("Calendar")),
            ],
            selected: {showCalendar},
            onSelectionChanged: (value) {
              setState(() {
                showCalendar = value.first;
              });
            },
          ),
        ),

        Expanded(
          child: StreamBuilder(
            stream: widget.repository.getTasksForUser(widget.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data!;

              if (showCalendar) {
                return CalendarPlannerView(
                  tasks: tasks,
                  service: widget.service,
                );
              }

              return WeeklyPlannerView(
                tasks: tasks,
                service: widget.service,
              );
            },
          ),
        ),
      ],
    );
  }
}