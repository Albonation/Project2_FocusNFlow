import 'package:focus_n_flow/models/task_model.dart';

class PlannedTask{
  final Task task;
  final double hoursForDay;

  PlannedTask({
    required this.task,
    required this.hoursForDay,
  });
}