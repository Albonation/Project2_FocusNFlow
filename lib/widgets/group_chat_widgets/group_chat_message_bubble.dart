import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/group_chat_message_model.dart';
import 'package:focus_n_flow/theme/app_corners.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class GroupChatMessageBubble extends StatelessWidget {
  final GroupChatMessage message;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;

  const GroupChatMessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isCurrentUser
        ? context.appColors.brand
        : context.appColors.surfaceMuted;

    final textColor = isCurrentUser ? Colors.white : context.colors.onSurface;

    final metaColor = isCurrentUser
        ? Colors.white.withValues(alpha: 0.8)
        : context.colors.onSurfaceVariant;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppCorners.lg),
                topRight: const Radius.circular(AppCorners.lg),
                bottomLeft: Radius.circular(
                  isCurrentUser ? AppCorners.lg : AppCorners.xs,
                ),
                bottomRight: Radius.circular(
                  isCurrentUser ? AppCorners.xs : AppCorners.lg,
                ),
              ),
              border: isCurrentUser
                  ? null
                  : Border.all(color: context.appColors.cardBorder),
            ),
            child: Padding(
              padding: AppSpacing.compactTilePadding,
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser) ...[
                    Text(
                      message.senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: context.appColors.group,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.gapXs,
                  ],

                  Text(
                    message.text,
                    style: context.text.bodyMedium?.copyWith(color: textColor),
                  ),

                  AppSpacing.gapXs,

                  Text(
                    _formatTime(message.createdAt),
                    style: context.text.labelSmall?.copyWith(
                      color: metaColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour == 0
        ? 12
        : hour > 12
        ? hour - 12
        : hour;

    return '$displayHour:$minute$period';
  }
}
