import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/student_dashboard_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class WeeklyPlannerScreen extends StatelessWidget{
  final String userId;
  final TaskRepository repository;
  final StudentDashboardService service;

  const WeeklyPlannerScreen({
    super.key,
    required this.userId,
    required this.repository,
    required this.service,
  });

  Map<String, List<Task>> _generatePlan(List<Task> tasks){
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final sorted = [...tasks];

    sorted.sort((a, b){
      final aScore = service.countCompletedTasks([a]);
      final bScore = service.countCompletedTasks([b]);
      return bScore.compareTo(aScore);
    });

    final plan = <String, List<Task>>{};

    for (int i = 0; i < sorted.length; i++){
      final day = days[i % 7];
      plan.putIfAbsent(day, () => []);
      plan[day]!.add(sorted[i]);
    }

    return plan;
  }

  @override
  Widget build(BuildContext context){
    return StreamBuilder<List<Task>>(
      stream: repository.getTasksForUser(userId),
      builder: (context, snapshot){
        if (!snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(child: Text("Add tasks to generate weekly plan")),
          );
        }
      })
  }
}