import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/unread_badge.dart';

void main() {
  testWidgets('count 0 does not render a visible badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UnreadBadge(count: 0))),
    );

    expect(find.text('0'), findsNothing);
    expect(find.bySemanticsLabel('0 mensajes no leidos'), findsNothing);
  });

  testWidgets('count from 1 to 99 renders the exact number', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UnreadBadge(count: 42))),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.bySemanticsLabel('42 mensajes no leidos'), findsOneWidget);
  });

  testWidgets('count greater than 99 is capped at 99+', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UnreadBadge(count: 128))),
    );

    expect(find.text('99+'), findsOneWidget);
    expect(find.bySemanticsLabel('99+ mensajes no leidos'), findsOneWidget);
  });
}
