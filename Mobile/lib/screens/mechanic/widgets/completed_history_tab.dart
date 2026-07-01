import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/ui_components.dart';

class CompletedHistoryTab extends StatelessWidget {
  const CompletedHistoryTab({super.key});

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
                  const Icon(Icons.history_rounded, color: AppTheme.green, size: 21),
                  const SizedBox(width: 10),
                  Text(
                    'Historial de Trabajos',
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Aquí usarías ListView.builder para mostrar varias tareas.
              ...List.generate(3, (index) {
                return _CompletedHistoryCard(
                  vehicle: index == 0 ? 'Ford F-150 2020' : (index == 1 ? 'Nissan Sentra 2019' : 'Honda CR-V 2021'),
                  plate: index == 0 ? 'XYZ-987' : (index == 1 ? 'DEF-456' : 'GHI-789'),
                  date: index == 0 ? 'Ayer, 04:15 PM' : (index == 1 ? 'Hace 2 días' : 'Hace 3 días'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedHistoryCard extends StatelessWidget {
  const _CompletedHistoryCard({
    required this.vehicle,
    required this.plate,
    required this.date,
  });

  final String vehicle;
  final String plate;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  Icons.check_circle_outline_rounded,
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
              const StatusChip(
                text: 'COMPLETADO',
                color: AppTheme.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const InfoLine(label: 'Servicio:', value: 'Mantenimiento Preventivo 50K'),
          const SizedBox(height: 8),
          InfoLine(label: 'Fecha:', value: date),
          const SizedBox(height: 8),
          const InfoLine(label: 'Tiempo:', value: '3 horas 15 min'),
        ],
      ),
    );
  }
}
