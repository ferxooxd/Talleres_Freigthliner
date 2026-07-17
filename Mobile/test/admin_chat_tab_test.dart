import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/providers/admin_provider.dart';
import 'package:mobile/screens/admin/widgets/admin_chat_tab.dart';
import 'package:provider/provider.dart';

class FakeAdminProvider extends AdminProvider {
  FakeAdminProvider(this._users);

  final List<UserModel> _users;

  @override
  bool get isLoading => false;

  @override
  List<UserModel> get users => _users;

  @override
  Future<void> fetchUsers() async {}
}

UserModel buildUser({
  required int id,
  required String nombre,
  required String apellido,
  required String rol,
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
      ChangeNotifierProvider<AdminProvider>.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: AdminChatTab())),
      ),
    );
    await tester.pump();

    expect(find.text('Ana Admin'), findsNothing);
    expect(find.text('Carlos Cliente'), findsOneWidget);
  });
}
