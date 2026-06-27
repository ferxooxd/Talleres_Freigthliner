class ServiceOrderModel {
  final int idOrden;
  final int idVehiculo;
  final String fechaIngreso;
  final String horaIngreso;
  final String clienteNombre;
  final String trabajosARealizar;
  final String estadoOrden;

  ServiceOrderModel({
    required this.idOrden,
    required this.idVehiculo,
    required this.fechaIngreso,
    required this.horaIngreso,
    required this.clienteNombre,
    required this.trabajosARealizar,
    required this.estadoOrden,
  });

  factory ServiceOrderModel.fromJson(Map<String, dynamic> json) {
    return ServiceOrderModel(
      idOrden: json['id_orden'] ?? 0,
      idVehiculo: json['id_vehiculo'] ?? 0,
      fechaIngreso: json['fecha_ingreso']?.toString() ?? '',
      horaIngreso: json['hora_ingreso']?.toString() ?? '',
      clienteNombre: json['cliente_nombre']?.toString() ?? '',
      trabajosARealizar: json['trabajos_a_realizar']?.toString() ?? 'Sin detalles',
      estadoOrden: json['estado_orden']?.toString() ?? 'EN_DIAGNOSTICO',
    );
  }
}
