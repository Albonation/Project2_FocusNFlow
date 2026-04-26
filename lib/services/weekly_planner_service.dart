import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/weekly_planner_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class WeeklyPlannerService extends StatelessWidget{
  final String userId;
  final TaskRepository repository;
  final WeeklyPlannerService service;

  const WeeklyPlannerService({
    super.key,
    required this.userId,
    required this.repository,
    required this.service,
  });
}