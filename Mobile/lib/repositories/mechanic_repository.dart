import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/service_order_model.dart';

class MechanicRepository {
  Future<List<ServiceOrderModel>> getMyAssignedOrders(int mechanicId) async {
    try {
      // Usaremos el endpoint general de admin por ahora, filtrando localmente
      // idealmente, el backend tendría un /mechanic/{id}/orders
      final response = await apiClient.get('/service-orders/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final orders = data.map((json) => ServiceOrderModel.fromJson(json)).toList();
        return orders.where((o) => o.idMecanico == mechanicId).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener órdenes asignadas');
    }
  }
  Future<String?> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await apiClient.post(
        '/upload-image/', 
        data: formData,
      );
      if (response.statusCode == 201) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  Future<void> submitReport(Map<String, dynamic> reportData) async {
    try {
      final response = await apiClient.post(
        '/technical-reports/',
        data: reportData,
      );
      if (response.statusCode != 201) {
        throw Exception('Error en el servidor al guardar el reporte');
      }
    } catch (e) {
      throw Exception('Error al enviar el reporte: $e');
    }
  }
}

