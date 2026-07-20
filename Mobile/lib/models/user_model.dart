import 'package:json_annotation/json_annotation.dart';
import 'user_role.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'id_usuario')
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? cedula;
  final String correo;
  final String rol;
  final String? especialidad;
  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;

  UserModel({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.cedula,
    required this.correo,
    required this.rol,
    this.especialidad,
    this.lastMessageAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get nombreCompleto => '$nombre $apellido';
  String get correoElectronico => correo;
  UserRole get userRole => UserRole.fromBackendValue(rol);
}
