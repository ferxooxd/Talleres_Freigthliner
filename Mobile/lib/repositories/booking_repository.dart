import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/booking_model.dart';

class BookingRepository {
  Future<BookingModel?> getLatestBooking() async {
    try {
      final response = await apiClient.get('/bookings/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isNotEmpty) {
          // Tomamos el último agendamiento registrado
          return BookingModel.fromJson(data.last);
        }
      }
      return null;
    } on DioException {
      // Idealmente enviar a un log, pero en app móvil evitamos prints en prod
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<BookingModel> createBooking({
    required int idUsuario,
    required int idVehiculo,
    required String fechaSolicitud,
    required String fechaCita,
    required String horaCita,
    String? observaciones,
  }) async {
    try {
      final response = await apiClient.post(
        '/bookings/',
        data: {
          'id_usuario': idUsuario,
          'id_vehiculo': idVehiculo,
          'fecha_solicitud': fechaSolicitud,
          'fecha_cita': fechaCita,
          'hora_cita': horaCita,
          'observaciones': observaciones,
        },
      );
      return BookingModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          e.response?.data['detail'] ?? 'Error al crear la cita',
        );
      }
      throw Exception('Error inesperado');
    }
  }

  Future<List<BookingModel>> getBookingsByUser(int idUsuario) async {
    try {
      final response = await apiClient.get('/bookings/user/$idUsuario');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<BookingModel> updateBooking({
    required int idAgendamiento,
    required String fechaCita,
    required String horaCita,
    String? observaciones,
  }) async {
    try {
      final response = await apiClient.put(
        '/bookings/$idAgendamiento',
        data: {
          'fecha_cita': fechaCita,
          'hora_cita': horaCita,
          'observaciones': observaciones,
        },
      );
      return BookingModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['detail'] ?? 'Error al reprogramar la cita');
      }
      throw Exception('Error inesperado');
    }
  }

  Future<void> cancelBooking(int idAgendamiento) async {
    try {
      await apiClient.delete('/bookings/$idAgendamiento');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['detail'] ?? 'Error al cancelar la cita');
      }
      throw Exception('Error inesperado');
    }
  }

  Future<List<dynamic>> getActiveOrdersByUser(int idUsuario) async {
    try {
      final response = await apiClient.get('/service-orders/client/$idUsuario/active');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
