import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/services/planner_engine.dart';

class PlannerController extends ChangeNotifier {
  final PlannerEngine engine;

  PlannerController({
    required this.engine,
  });

  List<Task> tasks = [];

  Plan? currentPlan;

  // ---------------------------
  // CREATE EMPTY PLAN
  // ---------------------------
  void createEmptyPlan() {
    currentPlan = Plan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "New Plan",
      createdAt: DateTime.now(),
      days: {},
    );

    notifyListeners();
  }

  // ---------------------------
  // AI GENERATION
  // ---------------------------
  void generateAIPlan() {
    currentPlan = engine.autoGenerate(tasks);
    notifyListeners();
  }

  // ---------------------------
  // MANUAL ALLOCATION
  // ---------------------------
  void addManualAllocation(Task task, DateTime day, double hours) {
    if (currentPlan == null) {
      createEmptyPlan();
    }

    final updatedDays = Map<DateTime, List<PlannedTask>>.from(
      currentPlan!.days,
    );

    updatedDays[day] ??= [];

    updatedDays[day]!.add(
      PlannedTask(
        taskId: task.id!,
        task: task,
        date: day,
        hours: hours,
      ),
    );

    currentPlan = currentPlan!.copyWith(days: updatedDays);

    notifyListeners();
  }

  // ---------------------------
  // REMOVE ALLOCATION
  // ---------------------------
  void removeAllocation(PlannedTask task) {
    if (currentPlan == null) return;

    final updatedDays = Map<DateTime, List<PlannedTask>>.from(
      currentPlan!.days,
    );

    updatedDays.forEach((day, list) {
      list.removeWhere((t) => t.taskId == task.taskId);
    });

    currentPlan = currentPlan!.copyWith(days: updatedDays);

    notifyListeners();
  }

  // ---------------------------
  // MOVE TASK (drag/drop)
  // ---------------------------
  void moveTask(PlannedTask task, DateTime newDay) {
    if (currentPlan == null) return;

    final updatedDays = Map<DateTime, List<PlannedTask>>.from(
      currentPlan!.days,
    );

    // remove from old day
    updatedDays.forEach((day, list) {
      list.removeWhere((t) => t.taskId == task.taskId);
    });

    // add to new day
    updatedDays[newDay] ??= [];

    updatedDays[newDay]!.add(
      task.copyWith(date: newDay),
    );

    currentPlan = currentPlan!.copyWith(days: updatedDays);

    notifyListeners();
  }

  // ---------------------------
  // SAVE (placeholder)
  // ---------------------------
  Future<void> savePlanToFirestore() async {
    if (currentPlan == null) return;

    // later: repository.save(currentPlan)
  }
}