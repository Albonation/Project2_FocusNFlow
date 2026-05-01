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

    _taskSub = taskStream.listen((data) async {
      _tasks = data;
      
      await refreshedPlan();
    });

    _planSub = repository
        .getPlanStream(userId, weekId)
        .listen((data) {
      _plan = data;
      notifyListeners();
    });
  }

  Future<void> refreshedPlan() async {

    //if no plan,, generate one
    if (_plan.isEmpty) {
      final map = engine.buildPlan(_tasks);
      _plan = map.values.expand((e) => e).toList();

      await repository.savePlan(userId, weekId, _plan);
      notifyListeners();
      return;
    }

    //otherwise => incremental rebalance
    final updated = await engine.rebalance(
      currentPlan: _plan,
      tasks: _tasks,
    );

    _plan = updated;

    await repository.savePlan(userId, weekId, plan);
    notifyListeners();
  }

  Future<void> moveTask(
    String taskId,
    DateTime newDate,
  ) async {
    final normalized = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
    );

    final updated = _plan.map((p) {
      if (p.taskId == taskId) {
        return PlannedTask(
          taskId: p.taskId,
          task: p.task,
          hoursForDay: p.hoursForDay,
          plannedDate: normalized,
        );
      }
      return p;
    }).toList();

    _plan = updated;
    notifyListeners();

    await repository.savePlan(userId, weekId, _plan);

    await refreshedPlan();
  }

  @override
  void dispose() {
    _taskSub?.cancel();
    _planSub?.cancel();
    super.dispose();
  }
}