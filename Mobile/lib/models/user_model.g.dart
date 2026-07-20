// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  idUsuario: (json['id_usuario'] as num).toInt(),
  nombre: json['nombre'] as String,
  apellido: json['apellido'] as String,
  telefono: json['telefono'] as String?,
  cedula: json['cedula'] as String?,
  correo: json['correo'] as String,
  rol: json['rol'] as String,
  especialidad: json['especialidad'] as String?,
  lastMessageAt: json['last_message_at'] == null
      ? null
      : DateTime.parse(json['last_message_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id_usuario': instance.idUsuario,
  'nombre': instance.nombre,
  'apellido': instance.apellido,
  'telefono': instance.telefono,
  'cedula': instance.cedula,
  'correo': instance.correo,
  'rol': instance.rol,
  'especialidad': instance.especialidad,
  'last_message_at': instance.lastMessageAt?.toIso8601String(),
};
