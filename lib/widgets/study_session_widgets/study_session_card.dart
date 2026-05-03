import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_session_model.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class StudySessionCard extends StatelessWidget {
  final StudySession session;
  final VoidCallback onTap;

  const StudySessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);
    final statusLabel = _statusLabel();
    final dateLabel = _formatDate(session.startsAt);
    final timeLabel = _formatTimeRange(session.startsAt, session.endsAt);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: context.appColors.focus.withValues(
                      alpha: 0.15,
                    ),
                    foregroundColor: context.appColors.focus,
                    child: const Icon(Icons.event_note_outlined),
                  ),

                  AppSpacing.horizontalGapMd,

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        AppSpacing.gapXs,

                        Text(
                          '$dateLabel • $timeLabel',
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _SessionStatusBadge(
                    label: statusLabel,
                    color: statusColor,
                    icon: _statusIcon(),
                  ),
                ],
              ),

              if (session.description.trim().isNotEmpty) ...[
                AppSpacing.gapMd,
                Text(
                  session.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],

              AppSpacing.gapMd,

              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (session.courseCode != null &&
                      session.courseCode!.trim().isNotEmpty)
                    _SessionInfoChip(
                      icon: Icons.school_outlined,
                      label: session.courseCode!,
                      color: context.appColors.task,
                    ),

                  if (session.roomName != null &&
                      session.roomName!.trim().isNotEmpty)
                    _SessionInfoChip(
                      icon: Icons.meeting_room_outlined,
                      label: session.roomName!,
                      color: context.appColors.studyRoom,
                    ),

                  _SessionInfoChip(
                    icon: Icons.groups_outlined,
                    label:
                    '${session.participantCount} joined',
                    color: context.appColors.group,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (session.status) {
      case StudySessionStatus.scheduled:
        return 'Scheduled';
      case StudySessionStatus.active:
        return 'Active';
      case StudySessionStatus.completed:
        return 'Completed';
      case StudySessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _statusIcon() {
    switch (session.status) {
      case StudySessionStatus.scheduled:
        return Icons.schedule;
      case StudySessionStatus.active:
        return Icons.play_circle_outline;
      case StudySessionStatus.completed:
        return Icons.check_circle_outline;
      case StudySessionStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (session.status) {
      case StudySessionStatus.scheduled:
        return context.appColors.planner;
      case StudySessionStatus.active:
        return context.appColors.success;
      case StudySessionStatus.completed:
        return context.colors.onSurfaceVariant;
      case StudySessionStatus.cancelled:
        return context.appColors.danger;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;

    return '$displayHour:$minute $period';
  }
}

class _SessionStatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SessionStatusBadge({
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
          Icon(
            icon,
            size: 13,
            color: color,
          ),
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

class _SessionInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SessionInfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.badge,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppCorners.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          AppSpacing.horizontalGapXs,
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}