import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/repositories/planner_firesto_repository.dart';
import 'planner_engine.dart';

class PlannerService {
  final TaskRepository taskRepository;
  final PlannerEngine engine;
  final PlannerFirestoreRepository plannerRepository;

  PlannerService({
    required this.taskRepository,
    required this.engine,
    required this.plannerRepository,
  });

  String weekId(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String();

  Stream<List<PlannedTask>> watchWeeklyPlanFromFirestore(
    String userId,
    DateTime weekStart,
  ) {
    return plannerRepository.getWeeklyPlan(userId, weekStart);
  }

  Future<void> generateAndSavePlanIfNeeded({
    required String uid,
    required DateTime weekStart,
  }) async {
    final week = weekId(weekStart);

    final alreadyGenerated =
        await plannerRepository.isPlanGenerated(uid, week);

    if (alreadyGenerated) return;

    try {
      final tasks = await taskRepository.getTasksForUser(uid).first;

      final plan = engine.generateWeeklyPlan(
        tasks: tasks,
        weekStart: weekStart,
      );

      await plannerRepository.savePlan(uid, weekStart, plan);
      await plannerRepository.markGenerated(uid, week);

    } catch (e) {
      debugPrint("Planner generation failed: $e");
    }
  }
}