import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/repositories/weekly_planner_repository.dart';

class PlannerEngine {
  final WeeklyPlannerRepository repository;
  final String userId;
  final String weekId;
  static const double maxHoursPerDay = 4.0;

  PlannerEngine({
    required this.repository,
    required this.userId,
    required this.weekId,
  });

  Future<void> persistMove(String taskId, DateTime newDate) async {
    await repository.movePlannedTask(
      userId,
      weekId,
      taskId,
      newDate,
    );
  }

  Map<DateTime, List<PlannedTask>> buildPlan(List<Task> tasks) {
    final now = DateTime.now();

    final days = List.generate(
      7,
      (i) => _normalize(DateTime(now.year, now.month, now.day + i)),
    );

    final map = <DateTime, List<PlannedTask>>{
      for (final d in days) d: <PlannedTask>[]
    };

    final active = tasks.where((t) => !t.isOverdue && t.id != null).toList();

    // sort by urgency first, priority second
    active.sort((a, b) {
      final aDays = 
        a.deadline.difference(DateTime.now()).inDays + 1;
      final bDays =
        b.deadline.difference(DateTime.now()).inDays + 1;

      final aScore = a.priorityScore / aDays;
      final bScore = b.priorityScore / bDays;

      return bScore.compareTo(aScore);
    });

    for (final task in active) {
      final distribution = distribute(task, days);

      applyCapacity(map, distribution);
    }

    return map;
  }

  // DISTRIBUTION STRATEGY

  List<PlannedTask> distribute(Task task, List<DateTime> days) {
    final availableDays = days
        .where((d) => !d.isAfter(task.deadline))
        .toList();

    if (availableDays.isEmpty || task.id == null) return [];

    double remaining = task.estimatedHours;
    final daysUntilDeadline =
      task.deadline.difference(DateTime.now()).inDays + 1;

    final urgencyMultiplier = 1/daysUntilDeadline;

    final result = <PlannedTask>[];

    // Create weights (front-loaded)
    final weights = List.generate(
      availableDays.length,
      (i) => (availableDays.length - i) * (1 + urgencyMultiplier), // earlier days heavier
    );

    final totalWeight =
        weights.fold<double>(0, (sum, w) => sum + w);

    for (int i = 0; i < availableDays.length; i++) {
    final day = availableDays[i];

    final weight = weights[i];

    double portion =
        (weight / totalWeight) * task.estimatedHours;

    if (portion > remaining) {
      portion = remaining;
    }

    if (portion <= 0) continue;

    result.add(
      PlannedTask(
        taskId: task.id!,
        task: task,
        hoursForDay: portion,
        plannedDate: _normalize(day),
      ),
    );

    remaining -= portion;

    if (remaining <= 0) break;
  }

    return result;
  }

  // CAPACITY CONSTRAINTS
  void applyCapacity(
    Map<DateTime, List<PlannedTask>> map,
    List<PlannedTask> tasks,
  ) {
    for (final task in tasks) {
      double remaining = task.hoursForDay;
      DateTime day = _normalize(task.plannedDate);

      while (remaining > 0) {
        final current = map[day] ?? [];

        final used = current.fold<double>(
          0,
          (sum, t) => sum + t.hoursForDay,
        );

        final free = maxHoursPerDay - used;

        if (free > 0) {
          final allocated = remaining > free ? free : remaining;

          map[day] = [
            ...current,
            PlannedTask(
              taskId: task.taskId,
              task: task.task,
              hoursForDay: allocated,
              plannedDate: day,
            ),
          ];

          remaining -= allocated;
        }

        // move to next day if full
        day = _normalize(day.add(const Duration(days: 1)));

        // safety stop (avoid infinite loop)
        if (!map.containsKey(day)) break;
      }
    }
  }

  // MOVE TASK (DRAG & DROP)
  Future<void> moveTaskAndRebalance(
    String taskId,
    DateTime newDate,
  ) async {
    await persistMove(taskId, newDate);
  }

  // HELPERS
  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);
}