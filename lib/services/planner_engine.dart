import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/models/planning_model.dart';
import 'package:focus_n_flow/repositories/weekly_planner_repository.dart';

class PlannerEngine {
  final WeeklyPlannerRepository repository;
  final TaskRepository repo;
  final String userId;
  final String weekId;
  static const double maxHoursPerDay = 12.0;
  late final List<DateTime> weekDays;

  PlannerEngine({
    required this.repository,
    required this.repo,
    required this.userId,
    required this.weekId,
  }) {
    final now = DateTime.now();

    weekDays = List.generate(
      7,
      (i) => _normalize(DateTime(now.year, now.month, now.day + i)),
    );
  }

  Future<void> persistMove(String taskId, DateTime newDate) async {
    await repository.movePlannedTask(
      userId,
      weekId,
      taskId,
      newDate,
    );
  }

  Map<DateTime, List<PlannedTask>> buildPlan(List<Task> tasks) {

    weekDays;

    final map = <DateTime, List<PlannedTask>>{
      for (final d in weekDays) d: <PlannedTask>[]
    };

    final active = tasks.where((t) => !t.isOverdue && t.id != null).toList();

    // sort by urgency first, priority second
    active.sort((a, b) {
      final aDays = 
        a.deadline.difference(_now).inDays + 1;
      final bDays =
        b.deadline.difference(_now).inDays + 1;

      final aScore = a.priorityScore / aDays;
      final bScore = b.priorityScore / bDays;

      return bScore.compareTo(aScore);
    });

    for (final task in active){
      final distributed = distribute(task, weekDays);

      if (distributed.isEmpty) continue;

      for (final part in distributed){
        _placeWithPressure(map, part);
      }
    }
    _mergeSameTasksPerDay(map);

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
    final map = <DateTime, List<PlannedTask>>{};

    // rebuild map from plan
    for (final p in currentPlan) {
      final day = _normalize(p.plannedDate);
      map.putIfAbsent(day, () => []).add(p);
    }

    // remove deleted tasks
    final validTaskIds = tasks.map((t) => t.id).toSet();

    map.forEach((day, list) {
      list.removeWhere((p) => !validTaskIds.contains(p.taskId));
    });

    //MAIN FIX: rebalance per task WITH lock awareness
    for (final task in tasks) {
      if (task.id == null) continue;

      _rebalanceSingleTaskWithLocks(map, task, weekDays);
    }
    _mergeSameTasksPerDay(map);

    return map.values.expand((e) => e).toList();
  }

  void _rebalanceSingleTaskWithLocks(
    Map<DateTime, List<PlannedTask>> map,
    Task task,
    List<DateTime> weekDays,
  ) {
    final taskId = task.id!;

    // ---------- STEP 1: collect locked ----------
    final locked = <PlannedTask>[];

    for (final list in map.values) {
      for (final p in list) {
        if (p.taskId == taskId && p.isLocked) {
          locked.add(p);
        }
      }
    }

    // ---------- STEP 2: remove ALL task entries ----------
    for (final list in map.values) {
      list.removeWhere((p) => p.taskId == taskId);
    }

    // ---------- STEP 3: calculate remaining ----------
    final lockedHours = locked.fold<double>(
      0,
      (sum, t) => sum + t.hoursForDay,
    );

    final remainingHours =
        (task.estimatedHours - lockedHours).clamp(0, double.infinity);

    // ---------- STEP 4: re-add locked ONLY ----------
    for (final p in locked) {
      map.putIfAbsent(p.plannedDate, () => []);
      map[p.plannedDate]!.add(p);
    }

    // nothing left to distribute
    if (remainingHours <= 0) return;

    // ---------- STEP 5: stable available days ----------
    final availableDays = weekDays
        .where((d) => !d.isAfter(task.deadline))
        .toList();

    if (availableDays.isEmpty) return;

    // ---------- STEP 6: distribute remaining ----------
    num remaining = remainingHours;

    for (int i = 0; i < availableDays.length; i++) {
      final day = availableDays[i];
      final daysLeft = availableDays.length - i;

      final portion = remaining / daysLeft;

      map.putIfAbsent(day, () => []);

      map[day]!.add(
        PlannedTask(
          taskId: taskId,
          task: task,
          hoursForDay: portion,
          plannedDate: day,
          isLocked: false,
        ),
      );

      remaining -= portion;
    }
  }
  // DISTRIBUTION STRATEGY

  List<PlannedTask> distribute(Task task, List<DateTime> days) {
    final availableDays = days
        .where((d) => !d.isAfter(task.deadline))
        .toList();

    if (availableDays.isEmpty || task.id == null) return [];

    double remaining = task.estimatedHours;
    final daysUntilDeadline =
      task.deadline.difference(_now).inDays + 1;

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

  List<PlannedTask> distributeRemaining(Task task, double remainingHours) {
    final days = _getAvailableDays(task);

    if (days.isEmpty) return [];

    final result = <PlannedTask>[];
    double remaining = remainingHours;

    for (int i = 0; i < days.length; i++){
      final day = days[i];
      final daysLeft = days.length - i;

      final portion = remaining / daysLeft;

      result.add(
        PlannedTask(
          taskId: task.id!,
          task: task, 
          hoursForDay: portion, 
          plannedDate: _normalize(day),
          isLocked: false,
        ),
      );

      remaining -= portion;
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
    int safety = 0;
    while (true) {
      if (++safety > 14) return;
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

        final existingIndex = current.indexWhere(
          (t) => t.taskId == newTask.taskId,
        );

        if (existingIndex != -1) {
          final existing = current[existingIndex];

          current[existingIndex] = PlannedTask(
            taskId: existing.taskId,
            task: existing.task,
            hoursForDay: existing.hoursForDay + allocated,
            plannedDate: day,
            isLocked: existing.isLocked,
          );

          map[day] = [...current];
        } else {
          map[day] = [
            ...current,
            PlannedTask(
              taskId: newTask.taskId,
              task: newTask.task,
              hoursForDay: allocated,
              plannedDate: day,
            ),
          ];
        }

        final remaining = newTask.hoursForDay - allocated;

        // if fully placed -> done
        if (remaining <= 0) return;

        // otherwise continue placing remainder
        newTask = PlannedTask(
          taskId: newTask.taskId,
          task: newTask.task,
          hoursForDay: remaining,
          plannedDate: day.add(const Duration(days: 1)),
        );

        if(remaining <= 0.01) return;
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

      if(day.isAfter(newTask.task!.deadline)) return;
    }
  }

  // MERGE SAME TASK
  void _mergeSameTasksPerDay(Map<DateTime, List<PlannedTask>> map) {
    map.forEach((day, list) {
      final grouped = <String, PlannedTask>{};

      for (final p in list) {
        final key = p.taskId;

        if (grouped.containsKey(key)) {
          final existing = grouped[key]!;

          grouped[key] = PlannedTask(
            taskId: existing.taskId,
            task: existing.task,
            hoursForDay: existing.hoursForDay + p.hoursForDay,
            plannedDate: day,

            // preserve lock if ANY part is locked
            isLocked: existing.isLocked || p.isLocked,
          );
        } else {
          grouped[key] = p;
        }
      }

      map[day] = grouped.values.toList();
    });
  }

  // MOVE TASK (DRAG & DROP)
  Future<void> moveTaskAndRebalance(
    String taskId,
    DateTime newDate,
  ) async {
    final normalized = _normalize(newDate);

    await persistMove(taskId, normalized);

    repo.getTasksForUser(userId).listen((tasks) async {
      final newPlan = buildPlan(tasks);

      await repository.savePlan(
        userId,
        weekId,
        newPlan.values.expand((e) => e).toList(),
      );
    });
  }

  // HELPERS
  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);
  
  DateTime get _now => DateTime.now();

  PlannedTask _findLowestPriority(List<PlannedTask> tasks) {
    tasks.sort((a, b) {
      final aScore = _urgencyScore(a.task!, _now);
      final bScore = _urgencyScore(b.task!, _now);
      return aScore.compareTo(bScore);
    });

    return tasks.first;
  }

  bool _isMoreUrgent(
    PlannedTask a,
    PlannedTask b,
  ) {
    final aScore = _urgencyScore(a.task!, _now);
    final bScore = _urgencyScore(b.task!, _now);

    return aScore > bScore;
  }

  double _urgencyScore(Task task, DateTime now) {
    final hoursLeft =
        task.deadline.difference(now).inHours.toDouble();

    final safeHours = hoursLeft.clamp(1, double.infinity);

    return task.priorityScore / safeHours;
  }

  List<DateTime> _getAvailableDays(Task task) {

    final weekDays = List.generate(
      7,
      (i) => _normalize(DateTime(_now.year, _now.month, _now.day + i)),
    );

    return weekDays
        .where((d) => !d.isAfter(task.deadline))
        .toList();
  }
}