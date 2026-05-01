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

  bool _isSaving = false; 

  void bind(Stream<List<Task>> taskStream) {
    _taskSub?.cancel();
    _planSub?.cancel();

    // TASK STREAM
    _taskSub = taskStream.listen((data) async {
      _tasks = data;

      if(_plan.isEmpty){
        await refreshPlan();
      }
      notifyListeners();
    });

    // PLAN STREAM (source of truth from DB)
    _planSub = repository
        .getPlanStream(userId, weekId)
        .listen((data) {
      if (_isSaving) return; 

      _plan = data;
      notifyListeners();
    });
  }

  // ---------- PLAN LOGIC ----------
  Future<void> refreshPlan() async {
    if (_tasks.isEmpty) return;

    List<PlannedTask> updated;

    if (_plan.isEmpty) {
      final map = engine.buildPlan(_tasks);
      updated = map.values.expand((e) => e).toList();
    } else {
      updated = await engine.rebalance(
        currentPlan: _plan,
        tasks: _tasks,
      );
    }

    _plan = updated;
    notifyListeners();

    // prevent stream echo loop
    _isSaving = true;
    await repository.savePlan(userId, weekId, _plan);
    _isSaving = false;
  }

  // ---------- TASKS FOR DAY --------
  List<PlannedTask> tasksForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);

    return _plan.where((p) {
      final d = DateTime(
        p.plannedDate.year,
        p.plannedDate.month,
        p.plannedDate.day,
      );

      return d == normalized;
    }).toList();
  }

  // ---------- DRAG & DROP ----------
  Future<void> moveTask(PlannedTask moved, DateTime newDate) async {
    final normalized = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
    );

    final existing = _plan.where((p) => p.taskId == taskId).toList();
    if (existing.isEmpty) return;

    final moved = existing.first;

    _plan
      ..remove(moved)
      ..add(
        PlannedTask(
          taskId: moved.taskId,
          task: moved.task,
          hoursForDay: moved.hoursForDay,
          plannedDate: normalized,
          isLocked: true,
        ),
      );

    notifyListeners();

    // persist ONLY
    _isSaving = true;
    await repository.savePlan(userId, weekId, _plan);
    _isSaving = false;
    
  }

  // ---------- WEEK GROUPING ----------
  Map<DateTime, List<PlannedTask>> groupedWeek() {
    final map = <DateTime, List<PlannedTask>>{};

    DateTime normalize(DateTime d) =>
        DateTime(d.year, d.month, d.day);

    for (final task in _plan) {
      final day = normalize(task.plannedDate);

      map.putIfAbsent(day, () => []);
      map[day]!.add(task);
    }

    // sort 
    for (final list in map.values) {
      list.sort((a, b) =>
          b.task!.priorityScore.compareTo(a.task!.priorityScore));
    }

    return map;
  }

  @override
  void dispose() {
    _taskSub?.cancel();
    _planSub?.cancel();
    super.dispose();
  }
}