import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/widgets/group_widgets/study_groups_section.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  void _openGroupChat(BuildContext context, StudyGroup group) {
    //##TODO: Replace this with the real group chat screen route when ready
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => GroupChatScreen(group: group),
    //   ),
    // );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Open chat for ${group.name}')));
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
