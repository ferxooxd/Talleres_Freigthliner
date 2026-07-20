import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/providers/admin_provider.dart';
import 'package:mobile/providers/chat_provider.dart';
import 'package:mobile/screens/admin/widgets/admin_chat_tab.dart';
import 'package:mobile/widgets/unread_badge.dart';
import 'package:provider/provider.dart';

class FakeAdminProvider extends AdminProvider {
  FakeAdminProvider(this._users);

  final List<UserModel> _users;

  @override
  bool get isLoading => false;

  @override
  List<UserModel> get users => _users;

  @override
  List<UserModel> get chatContacts => _users;

  @override
  Future<void> fetchUsers() async {}

  @override
  Future<void> fetchChatContacts() async {}
}

UserModel buildUser({
  required int id,
  required String nombre,
  required String apellido,
  required String rol,
  DateTime? lastMessageAt,
}) {
  return UserModel(
    idUsuario: id,
    nombre: nombre,
    apellido: apellido,
    telefono: '3000000000',
    cedula: '$id',
    correo: '$id@example.com',
    rol: rol,
    especialidad: null,
    lastMessageAt: lastMessageAt,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('filters admin users using backend role value', (tester) async {
    final provider = FakeAdminProvider([
      buildUser(id: 1, nombre: 'Ana', apellido: 'Admin', rol: 'Administrador'),
      buildUser(id: 2, nombre: 'Carlos', apellido: 'Cliente', rol: 'Cliente'),
    ]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AdminProvider>.value(value: provider),
          ChangeNotifierProvider<ChatProvider>.value(value: ChatProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: AdminChatTab())),
      ),
    );
    await tester.pump();

    expect(find.text('Ana Admin'), findsNothing);
    expect(find.text('Carlos Cliente'), findsOneWidget);
  });

  testWidgets('shows unread badge for the matching chat user only', (
    tester,
  ) async {
    final adminProvider = FakeAdminProvider([
      buildUser(id: 2, nombre: 'Carlos', apellido: 'Cliente', rol: 'Cliente'),
      buildUser(id: 3, nombre: 'Marta', apellido: 'Mecanica', rol: 'Mecanico'),
    ]);
    final chatProvider = ChatProvider();
    chatProvider.handleSocketData(
      jsonEncode({
        'id': 101,
        'sender_id': 2,
        'receiver_id': 1,
        'content': 'Pendiente',
        'timestamp': '2026-07-17T15:10:00Z',
        'is_read': false,
        'status': 'sent',
      }),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AdminProvider>.value(value: adminProvider),
          ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
        ],
        child: const MaterialApp(home: Scaffold(body: AdminChatTab())),
      ),
    );
    await tester.pump();

    expect(find.text('Carlos Cliente'), findsOneWidget);
    expect(find.text('Marta Mecanica'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.bySemanticsLabel('1 mensajes no leidos'), findsOneWidget);
  });

  testWidgets('orders chats by latest message activity', (tester) async {
    final adminProvider = FakeAdminProvider([
      buildUser(
        id: 2,
        nombre: 'Carlos',
        apellido: 'Cliente',
        rol: 'Cliente',
        lastMessageAt: DateTime.parse('2026-07-17T09:00:00Z'),
      ),
      buildUser(
        id: 3,
        nombre: 'Marta',
        apellido: 'Mecanica',
        rol: 'Tecnico',
        lastMessageAt: DateTime.parse('2026-07-17T11:00:00Z'),
      ),
      buildUser(
        id: 4,
        nombre: 'Sara',
        apellido: 'Secretaria',
        rol: 'Secretario',
      ),
    ]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AdminProvider>.value(value: adminProvider),
          ChangeNotifierProvider<ChatProvider>.value(value: ChatProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: AdminChatTab())),
      ),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Marta Mecanica')).dy,
      lessThan(tester.getTopLeft(find.text('Carlos Cliente')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Carlos Cliente')).dy,
      lessThan(tester.getTopLeft(find.text('Sara Secretaria')).dy),
    );
  });

  testWidgets('moves a chat to the top when a live message arrives', (
    tester,
  ) async {
    final adminProvider = FakeAdminProvider([
      buildUser(
        id: 2,
        nombre: 'Carlos',
        apellido: 'Cliente',
        rol: 'Cliente',
        lastMessageAt: DateTime.parse('2026-07-17T09:00:00Z'),
      ),
      buildUser(
        id: 3,
        nombre: 'Marta',
        apellido: 'Mecanica',
        rol: 'Tecnico',
        lastMessageAt: DateTime.parse('2026-07-17T08:00:00Z'),
      ),
    ]);
    final chatProvider = ChatProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AdminProvider>.value(value: adminProvider),
          ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
        ],
        child: const MaterialApp(home: Scaffold(body: AdminChatTab())),
      ),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Carlos Cliente')).dy,
      lessThan(tester.getTopLeft(find.text('Marta Mecanica')).dy),
    );

    chatProvider.handleSocketData(
      jsonEncode({
        'id': 201,
        'sender_id': 3,
        'receiver_id': 1,
        'content': 'Nuevo mensaje',
        'timestamp': '2026-07-17T12:00:00Z',
        'is_read': false,
        'status': 'sent',
      }),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Marta Mecanica')).dy,
      lessThan(tester.getTopLeft(find.text('Carlos Cliente')).dy),
    );
  });

  testWidgets('uses minimal avatars and compact unread badges', (tester) async {
    final adminProvider = FakeAdminProvider([
      buildUser(id: 2, nombre: 'Carlos', apellido: 'Cliente', rol: 'Cliente'),
    ]);
    final chatProvider = ChatProvider();
    chatProvider.handleSocketData(
      jsonEncode({
        'id': 101,
        'sender_id': 2,
        'receiver_id': 1,
        'content': 'Pendiente',
        'timestamp': '2026-07-17T15:10:00Z',
        'is_read': false,
        'status': 'sent',
      }),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AdminProvider>.value(value: adminProvider),
          ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
        ],
        child: const MaterialApp(home: Scaffold(body: AdminChatTab())),
      ),
    );
    await tester.pump();

    final avatar = tester.widget<Container>(
      find.ancestor(of: find.text('C').first, matching: find.byType(Container)),
    );
    final avatarDecoration = avatar.decoration! as BoxDecoration;
    final avatarBorder = avatarDecoration.border! as Border;

    expect(avatar.constraints!.minWidth, 38);
    expect(avatar.constraints!.minHeight, 38);
    expect(avatarDecoration.shape, BoxShape.circle);
    expect(avatarBorder.top.width, 0.8);

    final badge = tester.widget<UnreadBadge>(
      find.byWidgetPredicate(
        (widget) => widget is UnreadBadge && widget.count == 1,
      ),
    );

    expect(badge.compact, isTrue);
  });
}
