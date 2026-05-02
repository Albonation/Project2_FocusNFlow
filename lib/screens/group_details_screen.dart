import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/models/study_session_model.dart';
import 'package:focus_n_flow/screens/group_chat_screen.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/study_session_widgets/study_sessions_section.dart';
import 'package:focus_n_flow/screens/create_study_session_screen.dart';

class GroupDetailsScreen extends StatelessWidget {
  final StudyGroup group;

  const GroupDetailsScreen({
    super.key,
    required this.group,
  });

  void _openGroupChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(group: group),
      ),
    );
  }

  void _openCreateSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateStudySessionScreen(group: group),
      ),
    );
  }

  void _openSessionDetails(BuildContext context, StudySession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateStudySessionScreen(
          group: group,
          session: session,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription = group.description.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        centerTitle: false,
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: context.appColors.group.withValues(
                          alpha: 0.15,
                        ),
                        foregroundColor: context.appColors.group,
                        child: Text(
                          group.name.trim().isEmpty
                              ? '?'
                              : group.name.trim()[0].toUpperCase(),
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      AppSpacing.horizontalGapMd,

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: context.text.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            AppSpacing.gapXs,

                            Text(
                              '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                              style: context.text.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (hasDescription) ...[
                    AppSpacing.gapMd,
                    Text(
                      group.description,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],

                  AppSpacing.gapLg,

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        _openGroupChat(context);
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Open Group Chat'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AppSpacing.gapXxl,

          StudySessionsSection(
            group: group,
            onCreateSession: () {
              _openCreateSession(context);
            },
            onOpenSession: (session) {
              _openSessionDetails(context, session);
            },
          ),
        ],
      ),
    );
  }
}