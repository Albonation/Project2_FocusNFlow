import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/weekly_planner_service.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/weekly_planner_widget.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  final TaskRepository _repository = TaskRepository();
  final WeeklyPlannerService _service = WeeklyPlannerService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Study Plan"),
      ),
      body: WeeklyPlannerWidget(
        userId: user.uid,
        repository: _repository,
        service: _service,
      ),
    );
  }
}