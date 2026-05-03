import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/planner_engine.dart';
import 'package:focus_n_flow/services/planner_service.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/day_section.dart';
import 'package:focus_n_flow/widgets/weekly_planner_widgets/planner_overview.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  late final PlannerService plannerService;
  late final TaskRepository taskRepository;

  @override
  void initState() {
    super.initState();

    taskRepository = TaskRepository();

    plannerService = PlannerService(
      taskRepository: taskRepository,
      engine: PlannerEngine(),
    );
  }

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final today = _normalize(DateTime.now());
    final weekStart = today;

    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Plan")),
      body: StreamBuilder<List<PlannedTask>>(
        stream: plannerService.watchWeeklyPlan(uid, weekStart),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plan = snapshot.data!;

          if (plan.isEmpty) {
            return const Center(child: Text("No tasks in weekly plan"));
          }

          final week = List.generate(
            7,
            (i) => today.add(Duration(days: i)),
          );

          return Column(
            children: [
              PlannerOverviewCard(),

              Expanded(
                child: ListView(
                  children: week.map((day) {
                    final tasksForDay = plan
                        .where((p) => _normalize(p.date) == _normalize(day))
                        .toList();

                    return DaySection(
                      date: day,
                      tasks: tasksForDay,
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}