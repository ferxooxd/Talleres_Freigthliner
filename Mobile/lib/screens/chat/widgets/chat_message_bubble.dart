import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/message_model.dart';
import 'message_status_icon.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.debugOnBuild,
  });

  final MessageModel message;
  final bool isMe;

  @visibleForTesting
  final VoidCallback? debugOnBuild;

  @override
  Widget build(BuildContext context) {
    debugOnBuild?.call();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 7),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.green : AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : null,
            bottomLeft: !isMe ? const Radius.circular(0) : null,
          ),
          border: isMe
              ? null
              : Border.all(color: AppTheme.borderColor(context)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.black : AppTheme.textColor(context),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isMe
                          ? Colors.black.withValues(alpha: 0.64)
                          : AppTheme.textMutedColor(context),
                      fontSize: 11,
                      height: 1,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    MessageStatusIcon(status: message.status),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? rawTimestamp) {
    if (rawTimestamp == null || rawTimestamp.isEmpty) return '';

    final parsed = DateTime.tryParse(rawTimestamp);
    if (parsed == null) return '';

    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)}';
  }
}
