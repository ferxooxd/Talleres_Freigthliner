enum UserRole {
  admin('Administrador'),
  mechanic('Tecnico'),
  secretary('Secretario'),
  client('Cliente'),
  unknown('');

  const UserRole(this.backendValue);

  final String backendValue;

  static UserRole fromBackendValue(String? value) {
    final normalized = _normalize(value);

    switch (normalized) {
      case 'administrador':
      case 'admin':
        return UserRole.admin;
      case 'tecnico':
      case 'mecanico':
      case 'mechanic':
        return UserRole.mechanic;
      case 'secretario':
      case 'secretaria':
      case 'secretary':
        return UserRole.secretary;
      case 'cliente':
      case 'client':
        return UserRole.client;
      default:
        return UserRole.unknown;
    }
  }

  static String _normalize(String? value) {
    if (value == null) return '';

    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(RegExp(r'\s+'), '');
  }
}
