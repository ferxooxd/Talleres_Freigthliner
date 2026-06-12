import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'TF',
          style: GoogleFonts.cinzel(
            fontSize: 64, // Un poco más grande ahora que está arriba
            fontWeight: FontWeight.bold,
            color: AppTheme.green,
            letterSpacing: 2,
            height: 1.0, // Para que no deje mucho espacio debajo
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'CENTRO AUTOMOTRIZ',
          style: GoogleFonts.lora(
            fontSize: 16, // Un poquito más pequeño para que no compita
            fontWeight: FontWeight.bold,
            color: AppTheme.green,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
