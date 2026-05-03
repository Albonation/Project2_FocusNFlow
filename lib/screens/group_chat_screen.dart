import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/group_chat_widgets/group_chat_section.dart';

class GroupChatScreen extends StatelessWidget {
  final StudyGroup group;

  const GroupChatScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group Chat')),
        body: Center(
          child: Padding(
            padding: AppSpacing.screen,
            child: Text(
              'You must be signed in to view this chat.',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(group.name), centerTitle: false),
      body: GroupChatSection(groupId: group.id, currentUserId: user.uid),
    );
  }
}
