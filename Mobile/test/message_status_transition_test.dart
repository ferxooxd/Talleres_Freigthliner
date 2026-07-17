import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/message_model.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/screens/chat/widgets/chat_message_bubble.dart';
import 'package:provider/provider.dart';

class CountingMessageBubble extends StatelessWidget {
  const CountingMessageBubble({
    super.key,
    required this.messageId,
    required this.onBuild,
  });

  final int messageId;
  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    return Selector<ChatProvider, MessageModel?>(
      selector: (_, provider) => provider.messageById(messageId),
      builder: (context, message, child) {
        if (message == null) return const SizedBox.shrink();

        return ChatMessageBubble(
          message: message,
          isMe: true,
          debugOnBuild: onBuild,
        );
      },
    );
  }
}

void main() {
  testWidgets('message_delivered event rebuilds only the affected bubble', (
    tester,
  ) async {
    final provider = ChatProvider();
    provider.replaceMessagesForTesting([
      MessageModel(
        id: 1,
        senderId: 1,
        receiverId: 2,
        content: 'Mensaje 1',
        timestamp: '2026-07-17T14:31:00',
        isRead: false,
      ),
      MessageModel(
        id: 2,
        senderId: 1,
        receiverId: 2,
        content: 'Mensaje 2',
        timestamp: '2026-07-17T14:32:00',
        isRead: false,
      ),
    ]);
    var firstBuilds = 0;
    var secondBuilds = 0;

    await tester.pumpWidget(
      ChangeNotifierProvider<ChatProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CountingMessageBubble(
                  key: const ValueKey('message-1'),
                  messageId: 1,
                  onBuild: () => firstBuilds += 1,
                ),
                CountingMessageBubble(
                  key: const ValueKey('message-2'),
                  messageId: 2,
                  onBuild: () => secondBuilds += 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(firstBuilds, 1);
    expect(secondBuilds, 1);

    provider.handleSocketData(
      jsonEncode({
        'type': 'message_delivered',
        'message_id': 1,
        'delivered_at': '2026-07-17T14:35:00Z',
      }),
    );
    await tester.pump();

    expect(firstBuilds, 2);
    expect(secondBuilds, 1);
    expect(find.bySemanticsLabel('Mensaje entregado'), findsOneWidget);
    expect(find.bySemanticsLabel('Mensaje enviado'), findsOneWidget);
  });
}
