import 'package:focus_n_flow/models/planned_task_model.dart';

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final PlannedTask task;

  TimeSlot({
    required this.start,
    required this.end,
    required this.task,
  });
}