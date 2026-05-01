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

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  void generatePlan(List<Task> input) {
    tasks = input;

    final days = List.generate(
      7,
      (i) => _normalize(DateTime.now().add(Duration(days: i))),
    );

    final generatedDays = engine.generate(
      tasks: tasks,
      days: days,
    );

    currentPlan = Plan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "Generated Plan",
      createdAt: DateTime.now(),
      days: Map<DateTime, List<PlannedTask>>.from(generatedDays),
    );

    notifyListeners();
  }

  void moveTask(PlannedTask task, DateTime newDay) {
    if (currentPlan == null) return;

    final oldDay = _normalize(task.date);
    final targetDay = _normalize(newDay);

    final updatedDays = Map<DateTime, List<PlannedTask>>.from(
      currentPlan!.days,
    );

    // ensure lists exist
    updatedDays.putIfAbsent(oldDay, () => []);
    updatedDays.putIfAbsent(targetDay, () => []);

    // remove from old day
    updatedDays[oldDay] = updatedDays[oldDay]!
        .where((t) => t.taskId != task.taskId)
        .toList();

    // check if task exists in target day
    final index = updatedDays[targetDay]!.indexWhere(
      (t) => t.taskId == task.taskId,
    );

    if (index != -1) {
      final existing = updatedDays[targetDay]![index];

      updatedDays[targetDay]![index] = existing.copyWith(
        hours: existing.hours + task.hours,
      );
    } else {
      updatedDays[targetDay]!.add(
        task.copyWith(date: newDay),
      );
    }

    currentPlan = currentPlan!.copyWith(
      days: updatedDays,
    );

    notifyListeners();
  }

  List<Plan> savedPlans = [];
  String? selectedPlanId;

  void savePlan(String? name) {
    if (currentPlan == null) return;

    final updated = currentPlan!.copyWith(
      name: name ?? currentPlan!.name,
    );

    currentPlan = updated;

    final index = savedPlans.indexWhere(
      (p) => p.id == updated.id,
    );

    if (index == -1) {
      savedPlans.add(updated);
    } else {
      savedPlans[index] = updated;
    }

    selectedPlanId = updated.id;

    notifyListeners();
  }

  void loadPlan(String id) {
    final plan = savedPlans.firstWhere(
      (p) => p.id == id,
    );

    currentPlan = plan;
    selectedPlanId = id;

    notifyListeners();
  }

  void setCurrentPlan(Plan plan) {
    currentPlan = plan;

    final index = savedPlans.indexWhere(
      (p) => p.id == plan.id,
    );

    if (index == -1) {
      savedPlans.add(plan);
    } else {
      savedPlans[index] = plan;
    }

    selectedPlanId = plan.id;

    notifyListeners();
  }

  void createEmptyPlan() {
    final now = DateTime.now();

    final days = List.generate(
      7,
      (i) => now.add(Duration(days: i)),
    );

    currentPlan = Plan(
      id: now.millisecondsSinceEpoch.toString(),
      name: "New Plan",
      createdAt: now,
      days: {
        for (final d in days) d: [],
      },
    );

    notifyListeners();
  }

  Future<Plan> generateFromPrompt(String prompt, List<Task> tasks) async {
    final now = DateTime.now();

    final mode = _extractMode(prompt);

    int daySpan = 7;

    if (mode == "urgent") daySpan = 3;
    if (mode == "light") daySpan = 10;

    final days = List.generate(
      daySpan,
      (i) => now.add(Duration(days: i)),
    );

    final sortedTasks = [...tasks];

    // smarter sorting based on mode
    if (mode == "urgent") {
      sortedTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
    } else if (mode == "light") {
      sortedTasks.shuffle();
    }

    final Map<DateTime, List<PlannedTask>> result = {
      for (final d in days) DateTime(d.year, d.month, d.day): []
    };

    int dayIndex = 0;

    for (final task in sortedTasks) {
      final day = days[dayIndex % days.length];

      result[DateTime(day.year, day.month, day.day)]!.add(
        PlannedTask(
          taskId: task.id!,
          task: task,
          date: day,
          hours: mode == "urgent" ? 3 : 2,
        ),
      );

      dayIndex++;
    }

    return Plan(
      id: now.millisecondsSinceEpoch.toString(),
      name: prompt.isEmpty ? "AI Plan" : prompt,
      createdAt: now,
      days: result,
    );
  }

  String _extractMode(String prompt) {
    final p = prompt.toLowerCase();

    if (p.contains("cram") || p.contains("urgent") || p.contains("asap")) {
      return "urgent";
    }

    if (p.contains("light") || p.contains("easy")) {
      return "light";
    }

    if (p.contains("exam") || p.contains("study")) {
      return "study";
    }

    return "normal";
  }

  void clearPlan() {
    currentPlan = null;
    notifyListeners();
  }
}