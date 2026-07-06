import 'package:json_annotation/json_annotation.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel {
  @JsonKey(name: 'id_vehiculo')
  final int idVehiculo;
  final String placa;
  final String marca;
  final String modelo;
  @JsonKey(name: 'tipo_vehiculo')
  final String tipoVehiculo;
  @JsonKey(name: 'rol_vehiculo')
  final String? rolVehiculo;
  @JsonKey(name: 'conductor_id')
  final int? conductorId;
  @JsonKey(name: 'conductor_nombre')
  final String? conductorNombre;
  @JsonKey(name: 'conductor_telefono')
  final String? conductorTelefono;

  VehicleModel({
    required this.idVehiculo,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.tipoVehiculo,
    this.rolVehiculo,
    this.conductorId,
    this.conductorNombre,
    this.conductorTelefono,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
}
