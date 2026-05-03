import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/repositories/planner_firesto_repository.dart';
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
  late final PlannerFirestoreRepository plannerRepository;

  bool _initialized = false;
  late final DateTime _weekStart;

  @override
  void initState() {
    super.initState();

    taskRepository = TaskRepository();
    plannerRepository = PlannerFirestoreRepository();

    plannerService = PlannerService(
      taskRepository: taskRepository,
      engine: PlannerEngine(), 
      plannerRepository: plannerRepository,
    );

    _weekStart = _normalize(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) async{
      if (_initialized) return;
      _initialized = true;

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await plannerService.generateAndSavePlanIfNeeded(
        uid: uid,
        weekStart: _weekStart,
      );
    });
  }

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Plan")),
      body: StreamBuilder<List<PlannedTask>>(
        stream: plannerRepository.getWeeklyPlan(uid, _weekStart),
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
            (i) => _weekStart.add(Duration(days: i)),
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