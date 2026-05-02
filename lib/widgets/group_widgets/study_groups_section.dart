import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/services/study_group_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/group_widgets/add_edit_study_group_dialog.dart';
import 'package:focus_n_flow/widgets/group_widgets/study_group_card.dart';

class StudyGroupsSection extends StatefulWidget {
  final void Function(StudyGroup group)? onOpenGroupChat;

  const StudyGroupsSection({
    super.key,
    this.onOpenGroupChat,
  });

  @override
  State<StudyGroupsSection> createState() => _StudyGroupsSectionState();
}

class _StudyGroupsSectionState extends State<StudyGroupsSection> {
  final StudyGroupService _groupService = StudyGroupService();

  late Future<Set<String>> _joinedGroupIds;

  final Set<String> _busyGroupIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _joinedGroupIds = _loadJoinedGroupIds();
  }

  Future<Set<String>> _loadJoinedGroupIds() {
    return _groupService.getCurrentUserGroupIds();
  }

  Future<void> _refreshJoinedGroupIds() async {
    final future = _loadJoinedGroupIds();

    setState(() {
      _joinedGroupIds = future;
    });

    await future;
  }

  Future<void> _showCreateGroupDialog() async {
    final result = await showDialog<StudyGroupFormResult>(
      context: context,
      builder: (context) {
        return const AddEditStudyGroupDialog(
          title: 'Create Study Group',
          confirmText: 'Create',
        );
      },
    );

    if (result == null || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final actionResult = await _groupService.createGroup(
      name: result.name,
      description: result.description,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    _showResult(actionResult);

    if (actionResult.success) {
      await _refreshJoinedGroupIds();
    }
  }

  Future<void> _showEditGroupDialog(StudyGroup group) async {
    final result = await showDialog<StudyGroupFormResult>(
      context: context,
      builder: (context) {
        return AddEditStudyGroupDialog(
          title: 'Edit Study Group',
          confirmText: 'Save',
          initialName: group.name,
          initialDescription: group.description,
        );
      },
    );

    if (result == null || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final actionResult = await _groupService.updateGroup(
      groupId: group.id,
      name: result.name,
      description: result.description,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    _showResult(actionResult);
  }

  Future<void> _confirmDeactivateGroup(StudyGroup group) async {
    final shouldDeactivate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Remove Group?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'This will remove "${group.name}" from the active study groups list.',
            style: context.text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldDeactivate != true || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _groupService.deactivateGroup(group.id);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    _showResult(result);

    if (result.success) {
      await _refreshJoinedGroupIds();
    }
  }

  Future<void> _joinGroup(StudyGroup group) async {
    if (_busyGroupIds.contains(group.id)) {
      return;
    }

    setState(() {
      _busyGroupIds.add(group.id);
    });

    final result = await _groupService.joinGroup(group.id);

    if (!mounted) return;

    setState(() {
      _busyGroupIds.remove(group.id);
    });

    _showResult(result);

    if (result.success) {
      await _refreshJoinedGroupIds();
    }
  }

  Future<void> _leaveGroup(StudyGroup group) async {
    if (_busyGroupIds.contains(group.id)) {
      return;
    }

    setState(() {
      _busyGroupIds.add(group.id);
    });

    final result = await _groupService.leaveGroup(group.id);

    if (!mounted) return;

    setState(() {
      _busyGroupIds.remove(group.id);
    });

    _showResult(result);

    if (result.success) {
      await _refreshJoinedGroupIds();
    }
  }

  void _openGroupChat(StudyGroup group) {
    if (widget.onOpenGroupChat != null) {
      widget.onOpenGroupChat!(group);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group chat for "${group.name}" is coming next.'),
      ),
    );
  }

  void _showResult(StudyGroupActionResult result) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? null : context.colors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudyGroup>>(
      stream: _groupService.watchActiveGroups(),
      builder: (context, groupsSnapshot) {
        if (groupsSnapshot.hasError) {
          return _GroupsErrorState(
            message: groupsSnapshot.error.toString(),
          );
        }

        if (groupsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final groups = groupsSnapshot.data ?? [];

        if (groups.isEmpty) {
          return _GroupsEmptyState(
            onCreateGroup: _showCreateGroupDialog,
          );
        }

        return FutureBuilder<Set<String>>(
          future: _joinedGroupIds,
          builder: (context, joinedGroupsSnapshot) {
            final joinedGroupIds = joinedGroupsSnapshot.data ?? {};

            if (joinedGroupsSnapshot.connectionState ==
                ConnectionState.waiting &&
                !joinedGroupsSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (joinedGroupsSnapshot.hasError) {
              return _GroupsErrorState(
                message: joinedGroupsSnapshot.error.toString(),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshJoinedGroupIds,
              child: ListView.separated(
                padding: AppSpacing.screen,
                itemCount: groups.length + 1,
                separatorBuilder: (context, index) {
                  return AppSpacing.gapMd;
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _GroupsHeader(
                      isSubmitting: _isSubmitting,
                      onCreateGroup: _showCreateGroupDialog,
                    );
                  }

                  final group = groups[index - 1];
                  final isOwner = _groupService.isCurrentUserGroupOwner(group);
                  final isMember = joinedGroupIds.contains(group.id);
                  final isBusy = _busyGroupIds.contains(group.id);

                  return StudyGroupCard(
                    group: group,
                    isOwner: isOwner,
                    isMember: isMember,
                    isBusy: isBusy,
                    onJoin: () => _joinGroup(group),
                    onLeave: () => _leaveGroup(group),
                    onEdit: () => _showEditGroupDialog(group),
                    onDelete: () => _confirmDeactivateGroup(group),
                    onOpenChat: () => _openGroupChat(group),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _GroupsHeader extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onCreateGroup;

  const _GroupsHeader({
    required this.isSubmitting,
    required this.onCreateGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Available Groups',
          style: context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          tooltip: 'Create group',
          color: context.appColors.brand,
          onPressed: isSubmitting ? null : onCreateGroup,
          icon: const Icon(Icons.group_add_outlined),
        ),
      ],
    );
  }
}

class _GroupsEmptyState extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const _GroupsEmptyState({
    required this.onCreateGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_2_outlined,
              size: 64,
              color: context.appColors.group,
            ),

            AppSpacing.gapLg,

            Text(
              'No study groups yet',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.gapSm,

            Text(
              'Create a group so classmates can join, chat, and later start study sessions together.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            AppSpacing.gapLg,

            FilledButton.icon(
              onPressed: onCreateGroup,
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupsErrorState extends StatelessWidget {
  final String message;

  const _GroupsErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Text(
          'Something went wrong loading study groups.\n\n$message',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.error,
          ),
        ),
      ),
    );
  }
}