import 'package:flutter/material.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/planner_engine.dart';
import 'package:focus_n_flow/services/planner_service.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/calendar_view.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/weekly_view.dart';
import 'package:focus_n_flow/repositories/weekly_planner_repository.dart';

class WeeklyPlannerWidget extends StatefulWidget {
  final String userId;
  final TaskRepository repository;
  final WeeklyPlannerRepository plannerRepository;

  const WeeklyPlannerWidget({
    super.key,
    required this.userId,
    required this.repository,
    required this.plannerRepository,
  });

  @override
  State<WeeklyPlannerWidget> createState() =>
      _WeeklyPlannerWidgetState();
}

class _WeeklyPlannerWidgetState extends State<WeeklyPlannerWidget> {
  bool showCalendar = false;

  late PlannerController controller;

  @override
  void initState() {
    super.initState();

    final engine = PlannerEngine(
      repository: widget.plannerRepository,
      userId: widget.userId,
      weekId: _currentWeekId(),
    );

    controller = PlannerController(
      repository: widget.plannerRepository,
      userId: widget.userId,
      weekId: _currentWeekId(),
      engine: engine,
    );

    controller.bind(
      widget.repository.getTasksForUser(widget.userId),
    );
  }

  String _currentWeekId() {
    final now = DateTime.now();
    return "${now.year}-W${_weekNumber(now)}";
  }

  int _weekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return ((date.difference(startOfYear).inDays) / 7).ceil();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TOGGLE
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

        // UI
        Expanded(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (showCalendar) {
                return CalendarPlannerView(
                  controller: controller,
                  userId: widget.userId,
                );
              }

              return WeeklyPlannerView(
                controller: controller,
              );
            },
          ),
        ),
      ],
    );
  }
}