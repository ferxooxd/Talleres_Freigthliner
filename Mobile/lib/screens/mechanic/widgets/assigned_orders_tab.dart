import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/ui_components.dart';

class AssignedOrdersTab extends StatelessWidget {
  const AssignedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.build_circle_rounded, color: AppTheme.green, size: 21),
                  const SizedBox(width: 10),
                  Text(
                    'Órdenes Asignadas',
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Aquí usarías ListView.builder para mostrar varias órdenes.
              // Simularemos 2 órdenes para mostrar el formato de lista.
              ...List.generate(2, (index) {
                return _AssignedOrderCard(
                  vehicle: index == 0 ? 'Toyota Hilux 2022' : 'Chevrolet Dmax 2020',
                  plate: index == 0 ? 'ABC-123' : 'XYZ-987',
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignedOrderCard extends StatelessWidget {
  const _AssignedOrderCard({
    required this.vehicle,
    required this.plate,
  });

  final String vehicle;
  final String plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF262626), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppTheme.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle,
                      style: GoogleFonts.rajdhani(
                        color: AppTheme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Placa: $plate',
                      style: GoogleFonts.dmSans(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Envolvemos el StatusChip en un Flexible o simplemente no forzamos su tamaño
              const StatusChip(
                text: 'EN DIAGNÓSTICO',
                color: AppTheme.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF222222)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trabajos a realizar:',
                  style: GoogleFonts.dmSans(
                    color: AppTheme.textDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Revisión de frenos delanteros\n• Cambio de aceite y filtros\n• Chequeo de suspensión',
                  style: GoogleFonts.dmSans(
                    color: AppTheme.text,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InfoLine(label: 'Cliente:', value: 'Carlos Mendoza'),
          const SizedBox(height: 8),
          const InfoLine(label: 'Ingreso:', value: 'Hoy, 08:30 AM'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  label: 'Agregar Nota',
                  icon: Icons.note_add_rounded,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  label: 'Actualizar',
                  icon: Icons.update_rounded,
                  isPrimary: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
