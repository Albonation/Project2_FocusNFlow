import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/planner_firesto_repository.dart';
import 'package:focus_n_flow/services/planner_engine.dart';

class PlannerController extends ChangeNotifier {
  final PlannerEngine engine;
  final PlannerFirestoreRepository firestore;

  PlannerController({
    required this.engine,
    required this.firestore,
  });

  Future<void> generateAndSavePlan(
    String uid,
    List<Task> tasks,
    DateTime weekStart,
  ) async {
    final plan = engine.generateWeeklyPlan(
      tasks: tasks,
      weekStart: weekStart,
    );

    await firestore.clearWeekPlan(uid, weekStart);
    await firestore.savePlan(uid, weekStart, plan);

  }
}