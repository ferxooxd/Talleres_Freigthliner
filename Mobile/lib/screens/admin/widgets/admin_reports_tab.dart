import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/service_order_model.dart';
import '../../../models/user_model.dart';
import '../../../core/utils/pdf_generator.dart';

class AdminReportsTab extends StatefulWidget {
  const AdminReportsTab({super.key});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchServiceOrders();
      context.read<AdminProvider>().fetchUsers(); // To load mechanics
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: () {
            final historyOrders = provider.serviceOrders.where((o) => 
                o.estadoOrden == 'LISTO_PARA_ENTREGA' || o.estadoOrden == 'ENTREGADO'
            ).toList();

            if (provider.isLoading && historyOrders.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.green));
            }

            if (historyOrders.isEmpty) {
              return const Center(
                child: Text('No hay órdenes finalizadas.', style: TextStyle(color: Colors.white70)),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await provider.fetchServiceOrders();
                await provider.fetchUsers();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                itemCount: historyOrders.length,
                itemBuilder: (context, index) {
                  final order = historyOrders[index];
                  return _buildHistoryCard(context, order, provider);
                },
              ),
            );
          }(),
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, ServiceOrderModel order, AdminProvider provider) {
    Color statusColor = AppTheme.green;
    if (order.estadoOrden == 'LISTO_PARA_ENTREGA') statusColor = AppTheme.amber;
    if (order.estadoOrden == 'ENTREGADO') statusColor = Colors.grey;

    final isAssigned = order.idMecanico != null;
    final assignedMechanic = isAssigned 
        ? provider.users.where((u) => u.idUsuario == order.idMecanico).firstOrNull 
        : null;

    final hasReport = order.informeTrabajo != null && order.informeTrabajo!.trim().isNotEmpty;
    final isDelivered = order.estadoOrden == 'ENTREGADO';

    return Card(
      color: const Color(0xFF0A0A0A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF242424)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.estadoOrden.replaceAll('_', ' '),
                    style: GoogleFonts.dmSans(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  order.numeroOrden,
                  style: GoogleFonts.dmSans(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              order.clienteNombre,
              style: GoogleFonts.rajdhani(
                color: AppTheme.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_rounded, order.clienteTelefono),
            _buildInfoRow(Icons.directions_car_filled_rounded, 'Vehículo ID: ${order.idVehiculo} - Km: ${order.kilometrajeIngreso}'),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF242424), height: 1),
            const SizedBox(height: 12),
            Text('Trabajos Realizados:', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              order.trabajosARealizar,
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppTheme.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAssigned ? 'Mecánico: ${assignedMechanic?.nombre ?? 'Desconocido'}' : 'Sin mecánico asignado',
                      style: GoogleFonts.dmSans(color: isAssigned ? Colors.white : AppTheme.textMuted, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (hasReport) ...[
              Builder(
                builder: (context) {
                  final rawText = order.informeTrabajo!;
                  String displayText = rawText;
                  List<String> imageUrls = [];
                  
                  final imgRegex = RegExp(r'\[IMAGENES\](.*?)\[/IMAGENES\]');
                  final match = imgRegex.firstMatch(rawText);
                  if (match != null) {
                    final imagesCsv = match.group(1) ?? '';
                    imageUrls = imagesCsv.split(',').where((u) => u.trim().isNotEmpty).toList();
                    displayText = rawText.replaceAll(imgRegex, '').trim();
                  }
                  
                  const apiBase = 'http://192.168.1.7:8000';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informe del Mecánico', style: GoogleFonts.dmSans(color: AppTheme.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(displayText, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14)),
                        if (imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Fotos de repuestos:', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 90,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: imageUrls.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final fullUrl = '$apiBase${imageUrls[i]}';
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(fullUrl, fit: BoxFit.contain),
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      fullUrl,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 90,
                                        height: 90,
                                        color: const Color(0xFF222222),
                                        child: const Icon(Icons.broken_image, color: Colors.white38),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            if (isDelivered) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _downloadPDF(context, order, assignedMechanic),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Descargar Orden (PDF)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF444444)),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _deliverOrder(context, order, provider),
                  icon: const Icon(Icons.handshake_rounded),
                  label: const Text('Confirmar Entrega Física'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _downloadPDF(context, order, assignedMechanic),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Descargar Orden (PDF)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF444444)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 16),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }

  void _downloadPDF(BuildContext context, ServiceOrderModel order, UserModel? mechanic) async {
    try {
      await PdfGenerator.generateServiceOrderPdf(order, mechanic);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generado y guardado en Documentos'), backgroundColor: AppTheme.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: AppTheme.red),
        );
      }
    }
  }

  Future<void> _deliverOrder(BuildContext context, ServiceOrderModel order, AdminProvider provider) async {
    try {
      await provider.deliverServiceOrder(order.idOrden);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehículo entregado al cliente.'), backgroundColor: AppTheme.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.red),
        );
      }
    }
  }
}
