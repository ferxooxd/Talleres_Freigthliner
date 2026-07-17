import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/models/message_status.dart';
import 'package:mobile/screens/chat/widgets/message_status_icon.dart';

void main() {
  testWidgets('sent status renders a single neutral check', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MessageStatusIcon(status: MessageStatus.sent)),
      ),
    );

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.done_all_rounded), findsNothing);
    expect(find.bySemanticsLabel('Mensaje enviado'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.check_rounded));
    expect(icon.color, Colors.black54);
  });

  testWidgets('delivered status renders neutral double checks', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageStatusIcon(status: MessageStatus.delivered),
        ),
      ),
    );

    expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('Mensaje entregado'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.done_all_rounded));
    expect(icon.color, Colors.black54);
    final opacity = tester.widget<Opacity>(
      find.ancestor(
        of: find.byIcon(Icons.done_all_rounded),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets('read status renders accent double checks', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MessageStatusIcon(status: MessageStatus.read)),
      ),
    );

    expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('Mensaje leido'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.done_all_rounded));
    expect(icon.color, AppTheme.green);
    final opacity = tester.widget<Opacity>(
      find.ancestor(
        of: find.byIcon(Icons.done_all_rounded),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 1);
  });
}
