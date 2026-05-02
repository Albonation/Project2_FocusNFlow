import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/study_group_model.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class StudyGroupCard extends StatelessWidget {
  final StudyGroup group;
  final bool isOwner;
  final bool isMember;
  final bool isBusy;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenChat;

  const StudyGroupCard({
    super.key,
    required this.group,
    required this.isOwner,
    required this.isMember,
    required this.isBusy,
    required this.onJoin,
    required this.onLeave,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenChat,
  });

  bool get _canOpenChat => isOwner || isMember;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppCorners.lg),
        onTap: _canOpenChat ? onOpenChat : null,
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GroupCardHeader(
                group: group,
                isOwner: isOwner,
                onEdit: onEdit,
                onDelete: onDelete,
              ),

              if (group.description.trim().isNotEmpty) ...[
                AppSpacing.gapMd,
                Text(
                  group.description,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],

              AppSpacing.gapLg,

              Row(
                children: [
                  _GroupStatusBadge(isOwner: isOwner, isMember: isMember),

                  const Spacer(),

                  if (_canOpenChat) ...[
                    TextButton.icon(
                      onPressed: onOpenChat,
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Chat'),
                    ),
                    AppSpacing.horizontalGapSm,
                  ],

                  if (!isOwner)
                    FilledButton(
                      onPressed: isBusy
                          ? null
                          : isMember
                          ? onLeave
                          : onJoin,
                      child: isBusy
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.colors.onPrimary,
                              ),
                            )
                          : Text(isMember ? 'Leave' : 'Join'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCardHeader extends StatelessWidget {
  final StudyGroup group;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GroupCardHeader({
    required this.group,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = group.name.trim().isEmpty
        ? '?'
        : group.name.trim()[0].toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: context.appColors.group.withValues(alpha: 0.15),
          foregroundColor: context.appColors.group,
          child: Text(
            firstLetter,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.gapXs,
              Row(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 14,
                    color: context.colors.onSurfaceVariant,
                  ),
                  AppSpacing.horizontalGapXs,
                  Text(
                    '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (isOwner)
          PopupMenuButton<_GroupMenuAction>(
            iconColor: context.colors.onSurfaceVariant,
            onSelected: (action) {
              switch (action) {
                case _GroupMenuAction.edit:
                  onEdit();
                  break;
                case _GroupMenuAction.delete:
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: _GroupMenuAction.edit,
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: _GroupMenuAction.delete,
                  child: Text(
                    'Remove',
                    style: TextStyle(color: context.appColors.danger),
                  ),
                ),
              ];
            },
          ),
      ],
    );
  }
}

class _GroupStatusBadge extends StatelessWidget {
  final bool isOwner;
  final bool isMember;

  const _GroupStatusBadge({required this.isOwner, required this.isMember});

  @override
  Widget build(BuildContext context) {
    final label = isOwner
        ? 'Owner'
        : isMember
        ? 'Member'
        : 'Open';

    final icon = isOwner
        ? Icons.star
        : isMember
        ? Icons.check
        : Icons.group_add_outlined;

    final color = isOwner
        ? context.appColors.planner
        : isMember
        ? context.appColors.success
        : context.appColors.group;

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
          Icon(icon, size: 14, color: color),
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

enum _GroupMenuAction { edit, delete }
