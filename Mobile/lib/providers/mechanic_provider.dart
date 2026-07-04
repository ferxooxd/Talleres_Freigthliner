import 'package:flutter/material.dart';
import '../models/service_order_model.dart';
import '../repositories/mechanic_repository.dart';

class MechanicProvider with ChangeNotifier {
  final MechanicRepository _repository = MechanicRepository();

  List<ServiceOrderModel> _assignedOrders = [];
  List<ServiceOrderModel> _completedOrders = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceOrderModel> get assignedOrders => _assignedOrders;
  List<ServiceOrderModel> get completedOrders => _completedOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAssignedOrders(int mechanicId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allMyOrders = await _repository.getMyAssignedOrders(mechanicId);
      // Hack: the current repo method gets ALL assigned orders and filters out ENTREGADO.
      // Let's modify the filtering logic locally based on what it returned.
      // For the mechanic, an order is 'completed' if a report has been submitted (informeTrabajo != null),
      // OR if the order is already in a completed state like LISTO_PARA_ENTREGA.
      _assignedOrders = allMyOrders.where((o) => (o.estadoOrden == 'EN_DIAGNOSTICO' || o.estadoOrden == 'EN_REPARACION') && (o.informeTrabajo == null || o.informeTrabajo!.trim().isEmpty)).toList();
      _completedOrders = allMyOrders.where((o) => o.estadoOrden == 'LISTO_PARA_ENTREGA' || (o.informeTrabajo != null && o.informeTrabajo!.trim().isNotEmpty)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitTechnicalReport({
    required int idOrden,
    required String diagnostico,
    required String recomendaciones,
    required String repuestosUsados,
    required List<String> imagePaths,
    required int mechanicId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Subir imágenes
      List<String> imageUrls = [];
      for (String path in imagePaths) {
        final url = await _repository.uploadImage(path);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      // 2. Crear payload
      final reportData = {
        "id_orden": idOrden,
        "diagnostico": diagnostico,
        "recomendaciones": recomendaciones,
        "repuestos_usados": repuestosUsados,
        "imagenes_repuestos": imageUrls.isNotEmpty ? imageUrls.join(',') : null,
      };

      // 3. Enviar reporte
      await _repository.submitReport(reportData);

      // 4. Recargar órdenes
      await loadAssignedOrders(mechanicId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }
}
