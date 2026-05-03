import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/widgets/group_widgets/study_groups_section.dart';

import 'group_chat_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  void _openGroupChat(BuildContext context, StudyGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupChatScreen(group: group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Groups'), centerTitle: true),
      body: StudyGroupsSection(
        onOpenGroupChat: (group) {
          _openGroupChat(context, group);
        },
      ),
    );
  }
}
