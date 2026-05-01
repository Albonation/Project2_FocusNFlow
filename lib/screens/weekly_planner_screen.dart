import 'package:flutter/material.dart';
import 'package:focus_n_flow/services/planner_service.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/console_view.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/calendar_view.dart';
import 'package:provider/provider.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlannerController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Planner"),
            actions: [
              IconButton(
                icon: Icon(
                  _showCalendar
                      ? Icons.keyboard
                      : Icons.calendar_month,
                ),
                onPressed: () {
                  setState(() => _showCalendar = !_showCalendar);
                },
              ),
            ],
          ),

          body: _showCalendar
              ? CalendarView(controller: controller)
              : PlannerConsole(controller: controller),
        );
      },
    );
  }
}