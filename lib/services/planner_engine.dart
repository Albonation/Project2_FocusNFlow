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

  Future<List<PlannedTask>> generateIfEmpty(
    List<Task> tasks,
    List<PlannedTask>? existingPlan,
  ) async {
    if (existingPlan != null && existingPlan.isNotEmpty) {
      return existingPlan;
    }

    final map = buildPlan(tasks);

    final flat = map.values.expand((e) => e).toList();

    return flat;
  }

  //REBALANCE METHOD
  Future<List<PlannedTask>> rebalance({
    required List<PlannedTask> currentPlan,
    required List<Task> tasks,
  }) async {
    final updatedPlan = <DateTime, List<PlannedTask>>{};

    //rebuild map from plan
    for (final p in currentPlan) {
      final day = _normalize(p.plannedDate);
      updatedPlan.putIfAbsent(day, () => []).add(p);
    }

    //detect changes
    final taskIds = tasks.map((t) => t.id).toSet();
    

    updatedPlan.forEach((day, list) {
      list.removeWhere((p) => !taskIds.contains(p.taskId));
    });

    for (final task in tasks) {
      if (task.id == null) continue;

      _rebalanceSingleTask(updatedPlan, task);
    }

    return updatedPlan.values.expand((e) => e).toList();
  }

  void _rebalanceSingleTask(
    Map<DateTime, List<PlannedTask>> plan,
    Task task,
  ) {
    final taskId = task.id!;

    //remove exsisting entries for the task
    for (final entry in plan.entries){
      entry.value.removeWhere((p) => p.taskId == taskId);
    }

    final now = DateTime.now();

    final days = List.generate(
      7,
      (i) => _normalize(DateTime(now.year, now.month, now.day + i)),
    );

    final distribution = distribute(task, days);

    applyCapacity(plan, distribution);
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
    List<PlannedTask> incoming,
  ) {
    for (final task in incoming) {
      _placeWithPressure(map, task);
    }
  }

  void _placeWithPressure(
    Map<DateTime, List<PlannedTask>> map,
    PlannedTask newTask,
  ) {
    DateTime day = _normalize(newTask.plannedDate);

    while (true) {
      final current = map[day] ?? [];

      final used = current.fold<double>(
        0,
        (sum, t) => sum + t.hoursForDay,
      );

      final free = maxHoursPerDay - used;

      //If space exists → place it
      if (free > 0) {
        final allocated =
            newTask.hoursForDay > free ? free : newTask.hoursForDay;

        map[day] = [
          ...current,
          PlannedTask(
            taskId: newTask.taskId,
            task: newTask.task,
            hoursForDay: allocated,
            plannedDate: day,
          ),
        ];

        final remaining = newTask.hoursForDay - allocated;

        // if fully placed -> done
        if (remaining <= 0) return;

        // otherwise continue placing remainder
        newTask = PlannedTask(
          taskId: newTask.taskId,
          task: newTask.task,
          hoursForDay: remaining,
          plannedDate: day,
        );
      }

      // No space -> apply pressure
      if (current.isNotEmpty) {
        final weakest = _findLowestPriority(current);

        if (_isMoreUrgent(newTask, weakest)) {
          //Replace weaker task
          map[day] = current.where((t) => t != weakest).toList();

          // Put weaker task back into system (push forward)
          _placeWithPressure(
            map,
            PlannedTask(
              taskId: weakest.taskId,
              task: weakest.task,
              hoursForDay: weakest.hoursForDay,
              plannedDate: _normalize(day.add(const Duration(days: 1))),
            ),
          );

          continue; //retry placing new task
        }
      }

      //Move forward if cannot replace
      day = _normalize(day.add(const Duration(days: 1)));

      //safety stop
      if (!map.containsKey(day)) return;
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

  PlannedTask _findLowestPriority(List<PlannedTask> tasks) {
    tasks.sort((a, b) {
      final aScore = _urgencyScore(a.task!);
      final bScore = _urgencyScore(b.task!);
      return aScore.compareTo(bScore);
    });

    return tasks.first;
  }

  bool _isMoreUrgent(PlannedTask a, PlannedTask b) {
    return _urgencyScore(a.task!) > _urgencyScore(b.task!);
  }

  double _urgencyScore(Task task) {
    final daysLeft =
        task.deadline.difference(DateTime.now()).inDays + 1;

    return task.priorityScore / daysLeft;
  }
}