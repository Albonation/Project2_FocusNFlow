import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/weekly_planner_repository.dart';
import 'package:focus_n_flow/services/planner_engine.dart';

class PlannerController extends ChangeNotifier {
  final PlannerEngine engine;
  final WeeklyPlannerRepository repository;
  final String userId;
  final String weekId;

  PlannerController({
    required this.engine,
    required this.repository,
    required this.userId,
    required this.weekId,
  });

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  List<PlannedTask> _plan = [];
  List<PlannedTask> get plan => _plan;

  StreamSubscription? _taskSub;
  StreamSubscription? _planSub;

  void bind(Stream<List<Task>> taskStream) {
    _taskSub?.cancel();
    _planSub?.cancel();

    _taskSub = taskStream.listen((data) {
      _tasks = data;
      notifyListeners();
    });

    _planSub = repository
        .getPlanStream(userId, weekId)
        .listen((data) {
      _plan = data;
      notifyListeners();
    });
  }

  Future<void> moveTask(
    String taskId,
    DateTime newDate,
  ) async {
    final updated = _plan.map((p) {
      if (p.taskId == taskId) {
        return PlannedTask(
          taskId: p.taskId,
          task: p.task,
          hoursForDay: p.hoursForDay,
          plannedDate: DateTime(
            newDate.year,
            newDate.month,
            newDate.day,
          ),
        );
      }
      return p;
    }).toList();

    _plan = updated;
    notifyListeners();

    await repository.savePlan(userId, weekId, _plan);
  }

  @override
  void dispose() {
    _taskSub?.cancel();
    _planSub?.cancel();
    super.dispose();
  }
}