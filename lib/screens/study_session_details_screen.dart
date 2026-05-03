import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/models/study_session_model.dart';
import 'package:focus_n_flow/models/session_participant_model.dart';
import 'package:focus_n_flow/services/study_session_service.dart';
import 'package:focus_n_flow/screens/create_study_session_screen.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_corners.dart';

class StudySessionDetailsScreen extends StatefulWidget {
  final StudyGroup group;
  final StudySession session;

  const StudySessionDetailsScreen({
    super.key,
    required this.group,
    required this.session,
  });

  @override
  State<StudySessionDetailsScreen> createState() =>
      _StudySessionDetailsScreenState();
}

class _StudySessionDetailsScreenState extends State<StudySessionDetailsScreen> {
  final StudySessionService _sessionService = StudySessionService();

  late final Stream<StudySession?> _sessionStream;
  late final Stream<List<SessionParticipant>> _participantStream;

  bool _isWorking = false;

  @override
  void initState() {
    super.initState();

    _sessionStream = _sessionService.watchSession(widget.session.id);
    _participantStream = _sessionService.watchParticipants(widget.session.id);
  }

  Future<void> _editSession(StudySession session) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateStudySessionScreen(group: widget.group, session: session),
      ),
    );
  }

  Future<void> _runAction(
    Future<StudySessionActionResult> Function() action,
  ) async {
    if (_isWorking) return;

    setState(() {
      _isWorking = true;
    });

    final result = await action();

    if (!mounted) return;

    setState(() {
      _isWorking = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _confirmCancelSession(StudySession session) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Cancel Session?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'This will cancel "${session.title}" and remove it from active scheduling.',
            style: context.text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Session'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Cancel Session',
                style: TextStyle(
                  color: context.appColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    await _runAction(() => _sessionService.cancelSession(session.id));
  }

  Future<void> _confirmCompleteSession(StudySession session) async {
    final shouldComplete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Complete Session?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Mark "${session.title}" as completed?',
            style: context.text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not Yet'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );

    if (shouldComplete != true) return;

    await _runAction(() => _sessionService.completeSession(session.id));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StudySession?>(
      stream: _sessionStream,
      initialData: widget.session,
      builder: (context, snapshot) {
        final session = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting &&
            session == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Study Session')),
            body: Padding(
              padding: AppSpacing.screen,
              child: Text(
                'Unable to load session: ${snapshot.error}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          );
        }

        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Study Session')),
            body: Padding(
              padding: AppSpacing.screen,
              child: Text(
                'This study session could not be found.',
                style: context.text.bodyMedium,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Study Session')),
          body: StreamBuilder<List<SessionParticipant>>(
            stream: _participantStream,
            builder: (context, participantSnapshot) {
              final participants = participantSnapshot.data ?? [];
              final currentUserId = _sessionService.currentUserId;

              final isCurrentUserParticipant =
                  currentUserId != null &&
                  participants.any((participant) {
                    return participant.userId == currentUserId &&
                        participant.status == SessionParticipantStatus.joined;
                  });

              return ListView(
                padding: AppSpacing.screen.copyWith(bottom: AppSpacing.xxl),
                children: [
                  _SessionHeaderCard(session: session),

                  AppSpacing.gapLg,

                  _SessionScheduleCard(session: session),

                  AppSpacing.gapLg,

                  _SessionContextCard(session: session),

                  AppSpacing.gapLg,

                  _SessionParticipationCard(
                    session: session,
                    participants: participants,
                    isLoadingParticipants:
                        participantSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !participantSnapshot.hasData,
                  ),

                  AppSpacing.gapXl,

                  _SessionActionsSection(
                    session: session,
                    isWorking: _isWorking,
                    isCurrentUserParticipant: isCurrentUserParticipant,
                    onStart: () {
                      _runAction(
                        () => _sessionService.startSession(session.id),
                      );
                    },
                    onEdit: () {
                      _editSession(session);
                    },
                    onCancel: () {
                      _confirmCancelSession(session);
                    },
                    onJoin: () {
                      _runAction(() => _sessionService.joinSession(session.id));
                    },
                    onLeave: () {
                      _runAction(
                        () => _sessionService.leaveSession(session.id),
                      );
                    },
                    onComplete: () {
                      _confirmCompleteSession(session);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SessionHeaderCard extends StatelessWidget {
  final StudySession session;

  const _SessionHeaderCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, session.status);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  foregroundColor: statusColor,
                  child: Icon(_statusIcon(session.status)),
                ),

                AppSpacing.horizontalGapMd,

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      AppSpacing.gapXs,

                      _StatusLabel(status: session.status, color: statusColor),
                    ],
                  ),
                ),
              ],
            ),

            if (session.description.trim().isNotEmpty) ...[
              AppSpacing.gapLg,
              Text(
                session.description,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionScheduleCard extends StatelessWidget {
  final StudySession session;

  const _SessionScheduleCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.gapMd,

            _DetailRow(
              icon: Icons.play_arrow_outlined,
              label: 'Starts',
              value: _formatDateTime(session.startsAt),
              color: context.appColors.planner,
            ),

            AppSpacing.gapMd,

            _DetailRow(
              icon: Icons.stop_outlined,
              label: 'Ends',
              value: _formatDateTime(session.endsAt),
              color: context.appColors.planner,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionContextCard extends StatelessWidget {
  final StudySession session;

  const _SessionContextCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final hasCourse =
        session.courseCode != null && session.courseCode!.trim().isNotEmpty;
    final hasRoom =
        session.roomName != null && session.roomName!.trim().isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Context',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.gapMd,

            _DetailRow(
              icon: Icons.school_outlined,
              label: 'Course',
              value: hasCourse ? session.courseCode! : 'No course selected',
              color: context.appColors.task,
            ),

            AppSpacing.gapMd,

            _DetailRow(
              icon: Icons.meeting_room_outlined,
              label: 'Study Room',
              value: hasRoom ? session.roomName! : 'No room selected',
              color: context.appColors.studyRoom,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionParticipationCard extends StatelessWidget {
  final StudySession session;
  final List<SessionParticipant> participants;
  final bool isLoadingParticipants;

  const _SessionParticipationCard({
    required this.session,
    required this.participants,
    required this.isLoadingParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final participantCount = participants.length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.groups_outlined,
              label: 'Participants',
              value: isLoadingParticipants
                  ? 'Loading participants...'
                  : '$participantCount joined',
              color: context.appColors.group,
            ),

            if (participants.isNotEmpty) ...[
              AppSpacing.gapMd,

              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: participants.map((participant) {
                  return Chip(
                    avatar: const Icon(Icons.person_outline, size: 18),
                    label: Text(participant.displayName),
                  );
                }).toList(),
              ),
            ],

            if (!isLoadingParticipants && participants.isEmpty) ...[
              AppSpacing.gapMd,

              Text(
                session.status == StudySessionStatus.active
                    ? 'No one has joined this active session yet.'
                    : 'Participants will appear here after the session starts.',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionActionsSection extends StatelessWidget {
  final StudySession session;
  final bool isWorking;
  final bool isCurrentUserParticipant;

  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onComplete;

  const _SessionActionsSection({
    required this.session,
    required this.isWorking,
    required this.isCurrentUserParticipant,
    required this.onStart,
    required this.onEdit,
    required this.onCancel,
    required this.onJoin,
    required this.onLeave,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);

    if (actions.isEmpty) {
      return Text(
        'No actions available for this session.',
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        AppSpacing.gapSm,

        const Divider(),

        AppSpacing.gapSm,

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: actions,
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    switch (session.status) {
      case StudySessionStatus.scheduled:
        return [
          FilledButton.icon(
            onPressed: isWorking ? null : onStart,
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Start'),
          ),
          OutlinedButton.icon(
            onPressed: isWorking ? null : onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
          OutlinedButton.icon(
            onPressed: isWorking ? null : onCancel,
            icon: Icon(Icons.cancel_outlined, color: context.appColors.danger),
            label: Text(
              'Cancel',
              style: TextStyle(
                color: context.appColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ];

      case StudySessionStatus.active:
        return [
          if (!isCurrentUserParticipant)
            FilledButton.icon(
              onPressed: isWorking ? null : onJoin,
              icon: const Icon(Icons.login_outlined),
              label: const Text('Join'),
            )
          else
            OutlinedButton.icon(
              onPressed: isWorking ? null : onLeave,
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Leave'),
            ),

          OutlinedButton.icon(
            onPressed: isWorking ? null : onComplete,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Complete'),
          ),
        ];

      case StudySessionStatus.completed:
      case StudySessionStatus.cancelled:
        return [];
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Icon(icon),
        ),

        AppSpacing.horizontalGapMd,

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              AppSpacing.gapXs,

              Text(
                value,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final StudySessionStatus status;
  final Color color;

  const _StatusLabel({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.badge,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppCorners.pill),
        border: Border.all(color: color),
      ),
      child: Text(
        _statusLabel(status),
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

IconData _statusIcon(StudySessionStatus status) {
  switch (status) {
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

String _statusLabel(StudySessionStatus status) {
  switch (status) {
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

Color _statusColor(BuildContext context, StudySessionStatus status) {
  switch (status) {
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

String _formatDateTime(DateTime dateTime) {
  return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${_formatTime(dateTime)}';
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
