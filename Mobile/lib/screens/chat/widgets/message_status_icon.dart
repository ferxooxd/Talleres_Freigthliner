import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/message_status.dart';

class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon({super.key, required this.status, this.size = 16});

  final MessageStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconData = status == MessageStatus.sent
        ? Icons.check_rounded
        : Icons.done_all_rounded;
    final color = status == MessageStatus.read
        ? AppTheme.green
        : Colors.black54;
    final opacity = status == MessageStatus.delivered ? 0.72 : 1.0;

    return Semantics(
      label: status.semanticsLabel,
      image: true,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: opacity,
          child: Icon(iconData, size: size, color: color),
        ),
      ),
    );
  }
}
