import 'package:flutter/material.dart';
import 'package:focus_n_flow/services/planner_service.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/console_view.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlannerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Planner"),
        actions: [
          if (_showCalendar)
            IconButton(
              icon: const Icon(Icons.console),
              onPressed: () {
                setState(() => _showCalendar = false);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {
                setState(() => _showCalendar = true);
              },
            )
        ],
      ),
      body: _showCalendar
          ? CalendarView(controller: controller)
          : PlannerConsole(controller: controller),
    );
  }
}