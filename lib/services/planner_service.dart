import 'package:flutter/foundation.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/models/time_slot_model.dart';
import 'package:focus_n_flow/services/planner_engine.dart';

class PlannerController extends ChangeNotifier {
  final PlannerEngine engine;

  PlannerController({required this.engine});

  List<Task> tasks = [];
  Plan? currentPlan;

  void createEmptyPlan() {
    currentPlan = Plan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "New Plan",
      createdAt: DateTime.now(),
      slots: {},
    );

    notifyListeners();
  }

  void generateAIPlan() {
    currentPlan = engine.autoGenerate(tasks);
    notifyListeners();
  }

  void addManualAllocation(Task task, DateTime day, double hours) {
    if (currentPlan == null) createEmptyPlan();

    final updated = Map<DateTime, List<TimeSlot>>.from(
      currentPlan!.slots,
    );

    updated[day] ??= [];

    final start = DateTime(day.year, day.month, day.day, 9); // default start

    updated[day]!.add(
      TimeSlot(
        start: start,
        end: start.add(Duration(hours: hours.toInt())),
        task: PlannedTask(
          taskId: task.id!,
          task: task,
          date: day,
          hours: hours,
        ),
      ),
    );

    currentPlan = currentPlan!.copyWith(slots: updated);

    notifyListeners();
  }

  void removeAllocation(TimeSlot slot) {
    if (currentPlan == null) return;

    final updated = Map<DateTime, List<TimeSlot>>.from(
      currentPlan!.slots,
    );

    updated.forEach((_, list) {
      list.removeWhere((s) => s.task.taskId == slot.task.taskId);
    });

    currentPlan = currentPlan!.copyWith(slots: updated);

    notifyListeners();
  }

  void moveSlot(TimeSlot slot, DateTime newDay, DateTime newStart) {
    if (currentPlan == null) return;

    final updated = Map<DateTime, List<TimeSlot>>.from(
      currentPlan!.slots,
    );

    updated.forEach((_, list) {
      list.removeWhere((s) => s.task.taskId == slot.task.taskId);
    });

    updated[newDay] ??= [];

    updated[newDay]!.add(
      TimeSlot(
        start: newStart,
        end: newStart.add(slot.end.difference(slot.start)),
        task: slot.task,
      ),
    );

    currentPlan = currentPlan!.copyWith(slots: updated);

    notifyListeners();
  }

  Future<void> savePlanToFirestore() async {
    if (currentPlan == null) return;
  }
}