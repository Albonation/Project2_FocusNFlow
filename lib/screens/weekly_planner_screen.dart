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

  @override
  Widget build(BuildContext context){
    return StreamBuilder<List<Task>>(
      stream: repository.getTasksForUser(userId),
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return Scaffold(
            body: Center(child: Text("Add tasks to generate weekly plan")),
          );
        }
      })
  }
}