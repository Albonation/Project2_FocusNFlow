import 'package:flutter/material.dart';
import 'package:focus_n_flow/theme/app_spacing.dart';
import 'package:focus_n_flow/theme/app_theme_extensions.dart';

class GroupChatInputBar extends StatefulWidget {
  final bool isSending;
  final Future<void> Function(String text) onSend;

  const GroupChatInputBar({
    super.key,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<GroupChatInputBar> createState() => _GroupChatInputBarState();
}

class _GroupChatInputBarState extends State<GroupChatInputBar> {
  final TextEditingController _messageController = TextEditingController();

  bool get _canSend =>
      _messageController.text.trim().isNotEmpty && !widget.isSending;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || widget.isSending) return;

    _messageController.clear();
    setState(() {});

    await widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final showActiveSendButton = _canSend || widget.isSending;
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: context.appColors.cardBorder)),
        ),
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText: 'Message your group...',
                  ),
                  onSubmitted: (_) {
                    _send();
                  },
                ),
              ),

              AppSpacing.horizontalGapSm,

              IconButton.filled(
                onPressed: _canSend ? _send : null,
                style: IconButton.styleFrom(
                  backgroundColor: showActiveSendButton
                      ? context.appColors.brand
                      : context.appColors.surfaceStrong,
                  foregroundColor: showActiveSendButton
                      ? Colors.white
                      : context.colors.onSurfaceVariant,
                  disabledBackgroundColor: showActiveSendButton
                      ? context.appColors.brand
                      : context.appColors.surfaceStrong,
                  disabledForegroundColor: showActiveSendButton
                      ? Colors.white
                      : context.colors.onSurfaceVariant,
                ),
                icon: widget.isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
