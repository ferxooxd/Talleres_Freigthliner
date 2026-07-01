import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class MechanicScheduleTab extends StatelessWidget {
  const MechanicScheduleTab({super.key});

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
                  const Icon(Icons.calendar_month_rounded, color: AppTheme.green, size: 21),
                  const SizedBox(width: 10),
                  Text(
                    'Mi Agenda',
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Aquí usarías ListView.builder para mostrar la agenda.
              ...List.generate(3, (index) {
                return _ScheduleItemCard(
                  day: (24 + index).toString(),
                  month: 'OCT',
                  time: index == 0 ? '08:00 AM' : (index == 1 ? '11:30 AM' : '02:00 PM'),
                  service: index == 0 ? 'Revisión General' : (index == 1 ? 'Mantenimiento 10K' : 'Frenos'),
                  vehicle: index == 0 ? 'Toyota Hilux (ABC-123)' : (index == 1 ? 'Ford Ranger (DEF-456)' : 'Kia Rio (GHI-789)'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleItemCard extends StatelessWidget {
  const _ScheduleItemCard({
    required this.day,
    required this.month,
    required this.time,
    required this.service,
    required this.vehicle,
  });

  final String day;
  final String month;
  final String time;
  final String service;
  final String vehicle;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF262626)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: GoogleFonts.rajdhani(
                    color: AppTheme.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  month,
                  style: GoogleFonts.dmSans(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$time - $service',
                  style: GoogleFonts.dmSans(
                    color: AppTheme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle,
                  style: GoogleFonts.dmSans(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
