import 'package:flutter/material.dart';
import 'package:focus_n_flow/models/group_chat_message_model.dart';
import 'package:focus_n_flow/services/group_chat_service.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';
import 'package:focus_n_flow/widgets/group_chat_widgets/group_chat_input_bar.dart';
import 'package:focus_n_flow/widgets/group_chat_widgets/group_chat_message_bubble.dart';

class GroupChatSection extends StatefulWidget {
  final String groupId;
  final String currentUserId;

  const GroupChatSection({
    super.key,
    required this.groupId,
    required this.currentUserId,
  });

  @override
  State<GroupChatSection> createState() => _GroupChatSectionState();
}

class _GroupChatSectionState extends State<GroupChatSection> {
  final GroupChatService _chatService = GroupChatService();

  //create one message stream object for this group chat and reuse it across rebuilds
  late final Stream<List<GroupChatMessage>> _messagesStream;

  @override
  void initState() {
    super.initState();

    _messagesStream = _chatService.watchMessages(widget.groupId);
  }

  bool _isSending = false;

  Future<void> _sendMessage(String text) async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    final result = await _chatService.sendTextMessage(
      groupId: widget.groupId,
      text: text,
    );

    if (!mounted) return;

    setState(() {
      _isSending = false;
    });

    if (!result.success) {
      _showMessage(result.message);
    }
  }

  Future<void> _deleteMessage(GroupChatMessage message) async {
    final shouldDelete = await _confirmDeleteMessage(message);

    if (!shouldDelete) return;

    final result = await _chatService.deleteMessage(
      groupId: widget.groupId,
      messageId: message.id,
    );

    if (!mounted) return;

    _showMessage(result.message);
  }

  Future<bool> _confirmDeleteMessage(GroupChatMessage message) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Message?',
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Do you want to delete this message?',
            style: context.text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Delete',
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

    return shouldDelete ?? false;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<GroupChatMessage>>(
            stream: _messagesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: AppSpacing.screen,
                    child: Text(
                      'Unable to load messages: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ),
                );
              }

              final messages = snapshot.data ?? [];

              if (messages.isEmpty) {
                return _EmptyChatState();
              }

              return ListView.builder(
                reverse: true, //this is what seems to snap it to the bottom
                padding: AppSpacing.screen,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isCurrentUser =
                      message.senderId == widget.currentUserId;

                  return Padding(
                    padding: AppSpacing.verticalXs,
                    child: GroupChatMessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      onLongPress: isCurrentUser
                          ? () {
                              _deleteMessage(message);
                            }
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),

        GroupChatInputBar(isSending: _isSending, onSend: _sendMessage),
      ],
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: context.appColors.group,
            ),

            AppSpacing.gapLg,

            Text(
              'No messages yet',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            AppSpacing.gapSm,

            Text(
              'Start the conversation with your study group.',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
