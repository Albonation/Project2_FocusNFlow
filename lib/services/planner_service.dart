import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'planner_engine.dart';

class PlannerService {
  final TaskRepository taskRepository;
  final PlannerEngine engine;

  PlannerService({
    required this.taskRepository,
    required this.engine,
  });

  Stream<List<PlannedTask>> watchWeeklyPlan(
    String userId,
    DateTime weekStart,
  ) {
    return taskRepository.getTasksForUser(userId).map((tasks) {
      final activeTasks =
          tasks.where((t) => t.status != TaskStatus.completed).toList();

      return engine.generateWeeklyPlan(
        tasks: activeTasks,
        weekStart: weekStart,
      );
    });
  }
}