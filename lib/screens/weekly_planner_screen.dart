import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/planned_task_model.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/repositories/planner_firesto_repository.dart';
import 'package:focus_n_flow/repositories/task_repository.dart';
import 'package:focus_n_flow/services/planner_engine.dart';
import 'package:focus_n_flow/services/planner_service.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  late final PlannerController controller;
  Map<String, Task> taskMap = {};

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    controller = PlannerController(
      engine: PlannerEngine(),
      firestore: PlannerFirestoreRepository(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_initialized) return;
      _initialized = true;

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final weekStart = _normalize(DateTime.now());

      final tasks = await TaskRepository()
        .getTasksForUser(uid)
        .first;

      if (tasks.isEmpty)return;

      taskMap = {
        for (var t in tasks) t.id!: t
      };

      await controller.generateAndSavePlan(
        uid, 
        tasks, 
        weekStart
      );

      setState(() {}); // refresh stream
    });
  }

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  String _dayLabel(DateTime date) {
    const days = [
      "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    ];
    return days[date.weekday - 1];
  }
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final today = _normalize(DateTime.now());
    final weekStart = today;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Plan"),
      ),
      body: StreamBuilder<List<PlannedTask>>(
        stream: controller.firestore.getWeeklyPlan(userId, weekStart),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plan = snapshot.data ?? [];

          final taskTotals = {
            for (final t in taskMap.values)
            t.id!: t.estimatedHours.ceil(),
          };

          if (plan.isEmpty) {
            return const Center(
              child: Text("No tasks in weekly plan"),
            );
          }

          final week = List.generate(
            7,
            (i) => today.add(Duration(days: i)),
          );

          for(final p in plan){
            debugPrint("${p.taskId} - ${p.unitIndex} - ${p.date}");
          }

          return ListView(
            children: week.map((day){
              final tasksForDay = plan
                  .where((p) =>
                      _normalize(p.date) == _normalize(day))
                  .toList();

              return  _DaySection(
                label: _dayLabel(day),
                date: day,
                tasks: tasksForDay,
                taskMap: taskMap,
                taskTotals: taskTotals,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
class _DaySection extends StatelessWidget {
  final String label;
  final DateTime date;
  final List<PlannedTask> tasks;
  final Map<String, Task> taskMap;
  final Map<String, int> taskTotals;

  const _DaySection({
    required this.label,
    required this.date,
    required this.tasks,
    required this.taskMap, 
    required this.taskTotals, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ExpansionTile(
        title: Text(
          "$label (${date.month}/${date.day})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: tasks.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("No tasks"),
                )
              ]
            : tasks.map((t) {
                final fullTask = taskMap[t.taskId];

                final totalUnits = taskTotals[t.taskId] ?? 1;

                return TaskCard(
                  task: t,
                  fullTask: fullTask,
                  totalUnits: totalUnits,
                );
              }).toList(),
      ),
    );
  }
}
class TaskCard extends StatefulWidget {
  final PlannedTask task;
  final Task? fullTask;
  final int totalUnits;

  const TaskCard({
    super.key,
    required this.task,
    required this.fullTask,
    required this.totalUnits,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _collapsedView(),
            secondChild: _expandedView(),
          ),
        ),
      ),
    );
  }

  Widget _collapsedView() {
    return Row(
      children: [
        const Icon(Icons.book, size: 18),
        const SizedBox(width: 8),
        Text(
          "${widget.fullTask?.title ?? "Task"} "
          "Session: Hour ${widget.task.unitIndex + 1} out of ${widget.totalUnits}",
        ),
      ],
    );
  }

  Widget _expandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Task Title: ${widget.fullTask?.title ?? "Unknown"}"),
        Text("Study Session #${widget.task.unitIndex + 1}"),
        const SizedBox(height: 6),
        Text("Scheduled: ${widget.task.date.month}/${widget.task.date.day}"),
        const SizedBox(height: 6),
        Text("Week Start: ${widget.task.weekStart.month}/${widget.task.weekStart.day}"),
      ],
    );
  }
}