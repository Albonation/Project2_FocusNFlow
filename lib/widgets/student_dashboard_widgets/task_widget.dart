import 'package:flutter/material.dart';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class Tasks extends StatelessWidget {
  final Stream<List<Task>> stream;

  const Tasks({super.key, required this.stream});

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
          return const Center(child: CircularProgressIndicator());
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
              child: Text('No tasks due today', style: context.text.bodyMedium),
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

  const _TaskDashboardRow({required this.task});

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
