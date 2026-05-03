import 'package:flutter/material.dart';
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
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TasksHeader(),
              AppSpacing.gapSm,
              const Divider(),
              AppSpacing.gapSm,
              Text(
                'Something went wrong loading tasks',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
          );
        }

        final tasks = snapshot.data ?? [];
        final todaysTasks = tasks.where(_isDueToday).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TasksHeader(),

            AppSpacing.gapSm,

            const Divider(),

            AppSpacing.gapSm,

            if (todaysTasks.isEmpty)
              Text(
                'No tasks due today',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              )
            else
              Column(
                children: todaysTasks.map((task) {
                  return Padding(
                    padding: AppSpacing.rowPadding,
                    child: _TaskDashboardCard(task: task),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}

class _TasksHeader extends StatelessWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.task_alt_outlined, color: context.appColors.task),

        AppSpacing.horizontalGapSm,

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Tasks",
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              AppSpacing.gapXs,

              Text(
                'Tasks with deadlines today',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskDashboardCard extends StatelessWidget {
  final Task task;

  const _TaskDashboardCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final statusColor = _statusColor(context, task);
    final hasDescription = task.description.trim().isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: () {
          //##TODO wire up features for tapping on tasks on dashboard
          //maybe features to delete, change state, complete
        },
        child: Padding(
          padding: AppSpacing.compactTilePadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_statusIcon(task), color: statusColor),

              AppSpacing.horizontalGapMd,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: isCompleted
                            ? context.colors.onSurfaceVariant
                            : context.colors.onSurface,
                      ),
                    ),

                    if (hasDescription) ...[
                      AppSpacing.gapXs,
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],

                    AppSpacing.gapSm,

                    Row(
                      children: [
                        _StatusBadge(
                          label: _statusLabel(task),
                          icon: _statusIcon(task),
                          color: statusColor,
                        ),

                        AppSpacing.horizontalGapSm,

                        _ImportanceBadge(task: task),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.horizontalGapSm,

              _DeadlineBadge(deadline: task.deadline),
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(Task task) {
    switch (task.status) {
      case TaskStatus.pending:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.timelapse;
      case TaskStatus.completed:
        return Icons.check_circle;
    }
  }

  String _statusLabel(Task task) {
    switch (task.status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  Color _statusColor(BuildContext context, Task task) {
    switch (task.status) {
      case TaskStatus.pending:
        return context.colors.onSurfaceVariant;
      case TaskStatus.inProgress:
        return context.appColors.planner;
      case TaskStatus.completed:
        return context.appColors.success;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.badge,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppCorners.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),

          AppSpacing.horizontalGapXs,

          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportanceBadge extends StatelessWidget {
  final Task task;

  const _ImportanceBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag_outlined, size: 13, color: context.appColors.task),

        AppSpacing.horizontalGapXs,

        Text(
          task.manualImportance.label,
          style: context.text.labelSmall?.copyWith(
            color: context.appColors.task,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final DateTime deadline;

  const _DeadlineBadge({required this.deadline});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.schedule_outlined,
          size: 16,
          color: context.colors.onSurfaceVariant,
        ),

        AppSpacing.gapXs,

        Text(
          _formatTime(deadline),
          textAlign: TextAlign.end,
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;

    return '$displayHour:$minute $period';
  }
}
