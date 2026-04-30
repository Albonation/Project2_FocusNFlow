import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/planner_engine.dart';

class PlannerController extends ChangeNotifier {
  final PlannerEngine engine;

  PlannerController({required this.engine});

  List<Task> _tasks = [];
  Map<DateTime, List<PlannedTask>> _plan = {};

  List<Task> get tasks => _tasks;
  Map<DateTime, List<PlannedTask>> get plan => _plan;

  StreamSubscription? _sub;

  void bind(Stream<List<PlannedTask>> stream) {
    _sub?.cancel();

    _sub = stream.listen((data) {
      final map = <DateTime, List<PlannedTask>>{};

      for(final t in data){
        final day = DateTime(
          t.plannedDate.year,
          t.plannedDate.month,
          t.plannedDate.day,
        );

        map.putIfAbsent(day, () => []);
        map[day]!.add(t);
      }

      _plan = map;
      notifyListeners();
    });
  }

  List<PlannedTask> tasksForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _plan[normalized] ?? [];
  }

  Map<DateTime, List<PlannedTask>> groupedWeek() => _plan;

  Future<void> moveTask(String taskId, DateTime newDate) async {
    // 1. update local task (so rebuild uses new date)
    _tasks = _tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(deadline: newDate);
      }
      return t;
    }).toList();

    // 2. persist to backend
    await engine.persistMove(taskId, newDate);

    // 3. rebuild entire plan
    _plan = engine.buildPlan(_tasks);

    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}