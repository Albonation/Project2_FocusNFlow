import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/task_model.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onStatusButtonPressed;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onLongPress,
    required this.onStatusButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);
    final isCompleted = task.status == TaskStatus.completed;
    final hasDescription = task.description.trim().isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusButton(
                task: task,
                color: statusColor,
                onPressed: onStatusButtonPressed,
              ),

              AppSpacing.horizontalGapMd,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
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
                        maxLines: 2,
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
                          label: _statusLabel(),
                          icon: _statusIcon(),
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

              _DeadlineBadge(task: task),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (task.status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  IconData _statusIcon() {
    switch (task.status) {
      case TaskStatus.pending:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.timelapse;
      case TaskStatus.completed:
        return Icons.check_circle;
    }
  }

  Color _statusColor(BuildContext context) {
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

class _StatusButton extends StatelessWidget {
  final Task task;
  final Color color;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.task,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Tooltip(
      message: isCompleted ? 'Reopen task' : 'Complete task',
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        onPressed: onPressed,
        icon: Icon(
          isCompleted ? Icons.restart_alt : Icons.check_circle_outline,
          color: isCompleted
              ? context.appColors.warning
              : context.appColors.success,
        ),
      ),
    );
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
  final Task task;

  const _DeadlineBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.event_outlined,
          size: 16,
          color: context.colors.onSurfaceVariant,
        ),
        AppSpacing.gapXs,
        Text(
          _formatDeadline(task.deadline),
          textAlign: TextAlign.end,
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDeadline(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
