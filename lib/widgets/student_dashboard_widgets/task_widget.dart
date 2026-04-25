import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class Tasks extends StatelessWidget {
  final Stream<List<Task>> stream;

  const Tasks({
    super.key,
    required this.stream,
  });

  bool _isDueToday(Task task) {
    final now = DateTime.now();
    final deadline = task.deadline;

    return deadline.year == now.year &&
        deadline.month == now.month &&
        deadline.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong loading tasks',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
          );
        }

        final tasks = snapshot.data ?? [];
        final todaysTasks = tasks.where(_isDueToday).toList();

        if (todaysTasks.isEmpty) {
          return Card(
            margin: AppSpacing.cardMargin,
            child: Padding(
              padding: AppSpacing.card,
              child: Text(
                'No tasks due today',
                style: context.text.bodyMedium,
              ),
            ),
          );
        }

        return Card(
          margin: AppSpacing.cardMargin,
          child: Padding(
            padding: AppSpacing.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Tasks",
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                AppSpacing.gapMd,

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todaysTasks.length,
                  itemBuilder: (context, index) {
                    final task = todaysTasks[index];

                    return Padding(
                      padding: AppSpacing.rowPadding,
                      child: _TaskDashboardRow(task: task),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskDashboardRow extends StatelessWidget {
  final Task task;

  const _TaskDashboardRow({
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;

    return Container(
      padding: AppSpacing.compactTilePadding,
      decoration: BoxDecoration(
        color: context.appColors.surfaceMuted,
        border: Border.all(color: context.appColors.cardBorder),
        borderRadius: BorderRadius.circular(AppCorners.md),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.check_circle_outline,
            color: isCompleted
                ? context.appColors.success
                : context.colors.onSurfaceVariant,
          ),

          AppSpacing.horizontalGapMd,

          Expanded(
            child: Text(
              task.title,
              style: context.text.bodyLarge?.copyWith(
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: isCompleted
                    ? context.colors.onSurfaceVariant
                    : context.colors.onSurface,
              ),
            ),
          ),

          AppSpacing.horizontalGapSm,

          Container(
            padding: AppSpacing.badge,
            decoration: BoxDecoration(
              border: Border.all(color: context.appColors.cardBorder),
              borderRadius: BorderRadius.circular(AppCorners.pill),
            ),
            child: Text(
              task.manualImportance.label,
              style: context.text.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


  //saving for reference
  /*@override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("No user logged in"),
      );
    }

    return StreamBuilder<List<Task>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong loading tasks"),
          );
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Text("No tasks yet"),
          );
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Tasks",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              task.manualImportance.label,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}*/