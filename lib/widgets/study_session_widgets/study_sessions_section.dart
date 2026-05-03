import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/models/study_session_model.dart';
import 'package:focus_n_flow/services/study_session_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/study_session_widgets/study_session_card.dart';

class StudySessionsSection extends StatefulWidget {
  final StudyGroup group;
  final VoidCallback onCreateSession;
  final void Function(StudySession session) onOpenSession;

  const StudySessionsSection({
    super.key,
    required this.group,
    required this.onCreateSession,
    required this.onOpenSession,
  });

  @override
  State<StudySessionsSection> createState() => _StudySessionsSectionState();
}

class _StudySessionsSectionState extends State<StudySessionsSection> {
  final StudySessionService _sessionService = StudySessionService();

  late Stream<List<StudySession>> _sessionsStream;

  @override
  void initState() {
    super.initState();
    _sessionsStream = _sessionService.watchSessionsForGroup(widget.group.id);
  }

  @override
  void didUpdateWidget(covariant StudySessionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.group.id != widget.group.id) {
      _sessionsStream = _sessionService.watchSessionsForGroup(widget.group.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StudySessionsHeader(onCreateSession: widget.onCreateSession),

        AppSpacing.gapSm,

        const Divider(),

        AppSpacing.gapSm,

        StreamBuilder<List<StudySession>>(
          stream: _sessionsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const LinearProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(
                'Unable to load study sessions: ${snapshot.error}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              );
            }

            final sessions = snapshot.data ?? [];

            if (sessions.isEmpty) {
              return _EmptySessionsState(
                onCreateSession: widget.onCreateSession,
              );
            }

            return Column(
              children: sessions.map((session) {
                return Padding(
                  padding: AppSpacing.rowPadding,
                  child: StudySessionCard(
                    session: session,
                    onTap: () {
                      widget.onOpenSession(session);
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StudySessionsHeader extends StatelessWidget {
  final VoidCallback onCreateSession;

  const _StudySessionsHeader({required this.onCreateSession});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Study Sessions',
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          tooltip: 'Create session',
          color: context.appColors.brand,
          onPressed: onCreateSession,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _EmptySessionsState extends StatelessWidget {
  final VoidCallback onCreateSession;

  const _EmptySessionsState({required this.onCreateSession});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.verticalMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No sessions scheduled yet.',
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          AppSpacing.gapMd,

          FilledButton.icon(
            onPressed: onCreateSession,
            icon: const Icon(Icons.event_available_outlined),
            label: const Text('Create Session'),
          ),
        ],
      ),
    );
  }
}
