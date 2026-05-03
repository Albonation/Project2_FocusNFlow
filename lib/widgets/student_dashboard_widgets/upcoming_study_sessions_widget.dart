import 'package:flutter/material.dart';
import 'package:focus_n_flow/screens/study_session_details_screen.dart';
import 'package:focus_n_flow/models/study_session_model.dart';
import 'package:focus_n_flow/services/study_session_service.dart';
import 'package:focus_n_flow/services/study_group_service.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class UpcomingStudySessions extends StatefulWidget {
  const UpcomingStudySessions({super.key});

  @override
  State<UpcomingStudySessions> createState() => _UpcomingStudySessionsState();
}

class _UpcomingStudySessionsState extends State<UpcomingStudySessions> {
  final StudySessionService _sessionService = StudySessionService();
  final StudyGroupService _groupService = StudyGroupService();

  late final Stream<List<StudySession>> _upcomingSessionsStream;

  @override
  void initState() {
    super.initState();

    _upcomingSessionsStream = _sessionService
        .watchUpcomingScheduledSessionsForCurrentUser(daysAhead: 2);
  }

  Future<void> _openSessionDetails(StudySession session) async {
    final group = await _groupService.getGroupById(session.groupId);

    if (!mounted) return;

    if (group == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open session group.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudySessionDetailsScreen(group: group, session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _UpcomingSessionsHeader(),

        AppSpacing.gapSm,

        const Divider(),

        AppSpacing.gapSm,

        StreamBuilder<List<StudySession>>(
          stream: _upcomingSessionsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const LinearProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(
                'Unable to load upcoming sessions: ${snapshot.error}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              );
            }

            final sessions = snapshot.data ?? [];

            if (sessions.isEmpty) {
              return Text(
                'No study sessions scheduled in the next two days.',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              );
            }

            final visibleSessions = sessions.take(3).toList();
            final hiddenCount = sessions.length - visibleSessions.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...visibleSessions.map((session) {
                  return Padding(
                    padding: AppSpacing.rowPadding,
                    child: _UpcomingSessionTile(
                      session: session,
                      onTap: () {
                        _openSessionDetails(session);
                      },
                    ),
                  );
                }),

                if (hiddenCount > 0) ...[
                  AppSpacing.gapSm,
                  Text(
                    '+$hiddenCount more upcoming session${hiddenCount == 1 ? '' : 's'}',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _UpcomingSessionsHeader extends StatelessWidget {
  const _UpcomingSessionsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.event_available_outlined, color: context.appColors.group),

        AppSpacing.horizontalGapSm,

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Study Sessions',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              AppSpacing.gapXs,

              Text(
                'Scheduled for the next couple of days',
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

class _UpcomingSessionTile extends StatelessWidget {
  final StudySession session;
  final VoidCallback onTap;

  const _UpcomingSessionTile({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasRoom =
        session.roomName != null && session.roomName!.trim().isNotEmpty;
    final hasCourse =
        session.courseCode != null && session.courseCode!.trim().isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.compactTilePadding,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: context.appColors.group.withValues(
                  alpha: 0.12,
                ),
                foregroundColor: context.appColors.group,
                child: const Icon(Icons.event_available_outlined),
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
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    AppSpacing.gapXs,

                    Text(
                      '${session.groupName} • ${_formatDateTime(session.startsAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (hasCourse || hasRoom) ...[
                      AppSpacing.gapXs,
                      Text(
                        [
                          if (hasCourse) session.courseCode!,
                          if (hasRoom) session.roomName!,
                        ].join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              AppSpacing.horizontalGapSm,

              _ParticipantBadge(count: session.participantCount),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} at ${_formatTime(dateTime)}';
  }

  static String _formatTime(DateTime dateTime) {
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

class _ParticipantBadge extends StatelessWidget {
  final int count;

  const _ParticipantBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.groups_outlined, size: 18, color: context.appColors.group),
        AppSpacing.gapXs,
        Text(
          count.toString(),
          style: context.text.labelSmall?.copyWith(
            color: context.appColors.group,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
