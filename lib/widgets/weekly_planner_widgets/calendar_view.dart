import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/weekly_planner_service.dart';

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
  
}