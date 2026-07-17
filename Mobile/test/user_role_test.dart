import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/user_role.dart';

void main() {
  group('UserRole.fromBackendValue', () {
    test('maps known backend role values', () {
      expect(UserRole.fromBackendValue('Administrador'), UserRole.admin);
      expect(UserRole.fromBackendValue('Tecnico'), UserRole.mechanic);
      expect(UserRole.fromBackendValue('Secretario'), UserRole.secretary);
      expect(UserRole.fromBackendValue('Cliente'), UserRole.client);
    });

    test('maps legacy and display aliases without crashing', () {
      expect(UserRole.fromBackendValue('ADMINISTRADOR'), UserRole.admin);
      expect(UserRole.fromBackendValue('Admin'), UserRole.admin);
      expect(UserRole.fromBackendValue('MECANICO'), UserRole.mechanic);
      expect(UserRole.fromBackendValue('Mecánico'), UserRole.mechanic);
      expect(UserRole.fromBackendValue('Técnico'), UserRole.mechanic);
    });

    test('falls back to unknown for unexpected values', () {
      expect(UserRole.fromBackendValue('Supervisor'), UserRole.unknown);
      expect(UserRole.fromBackendValue(''), UserRole.unknown);
      expect(UserRole.fromBackendValue(null), UserRole.unknown);
    });
  });
}
