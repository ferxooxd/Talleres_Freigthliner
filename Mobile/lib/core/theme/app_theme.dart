import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Colores fijos (acento, estado) ──────────────────────────────────────
  static const Color green     = Color(0xFF22c55e);
  static const Color greenDim  = Color(0xFF16a34a);
  static const Color greenBg   = Color(0x1422c55e);
  static const Color borderGreen = Color(0x4D22c55e);
  static const Color amber     = Color(0xFFf59e0b);
  static const Color red       = Color(0xFFef4444);
  static const Color blue      = Color(0xFF3b82f6);

  // ─── Alias de compatibilidad (dark) ──────────────────────────────────────
  static const Color bg           = Color(0xFF0B1121);
  static const Color surface      = Color(0xFF131A2A);
  static const Color surface2     = Color(0xFF1E293B);
  static const Color surface3     = Color(0xFF222222);
  static const Color text         = Color(0xFFf5f5f5);
  static const Color textMuted    = Color(0xFF888888);
  static const Color textDim      = Color(0xFF555555);
  static const Color border       = Color(0x11FFFFFF);
  static const Color primaryColor = green;
  static const Color surfaceColor = surface;
  static const Color errorColor   = red;

  // ─── Colores adaptables según el tema activo ─────────────────────────────
  /// Fondo principal del Scaffold
  static Color bgColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF0B1121)
          : const Color(0xFFF3F4F6);

  /// Fondo de tarjetas / cards
  static Color cardColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF131A2A)
          : Colors.white;

  /// Fondo de inputs
  static Color inputColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF9FAFB);

  /// Color principal de texto
  static Color textColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFFf5f5f5)
          : const Color(0xFF111827);

  /// Texto secundario / subtítulos
  static Color textMutedColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF888888)
          : const Color(0xFF6B7280);

  /// Color de borde / divisores
  static Color borderColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0x22FFFFFF)
          : const Color(0xFFE5E7EB);

  /// AppBar background
  static Color appBarColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF0D1526)
          : Colors.white;

  /// BottomNavigationBar background
  static Color navBarColor(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF0D1526)
          : Colors.white;

  // ─── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: green,
      colorScheme: ColorScheme.dark(
        primary: green,
        surface: surface,
        error: red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1526),
        foregroundColor: Color(0xFFf5f5f5),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0D1526),
      ),
      cardColor: surface,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        bodyMedium: GoogleFonts.dmSans(color: text),
        bodySmall:  GoogleFonts.dmSans(color: textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:  GoogleFonts.dmSans(color: textDim,   fontSize: 13),
        labelStyle: GoogleFonts.dmSans(color: textMuted, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: green, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red, width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    const lightBg      = Color(0xFFF3F4F6);
    const lightSurface = Colors.white;
    const lightText    = Color(0xFF111827);
    const lightMuted   = Color(0xFF6B7280);
    const lightBorder  = Color(0xFFE5E7EB);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: green,
      colorScheme: ColorScheme.light(
        primary: green,
        surface: lightSurface,
        error: red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightText,
        elevation: 0,
        shadowColor: lightBorder,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: green,
        unselectedItemColor: lightMuted,
      ),
      cardColor: lightSurface,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ).copyWith(
        bodyMedium: GoogleFonts.dmSans(color: lightText),
        bodySmall:  GoogleFonts.dmSans(color: lightMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:  GoogleFonts.dmSans(color: lightMuted, fontSize: 13),
        labelStyle: GoogleFonts.dmSans(color: lightMuted, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: green, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red, width: 1),
        ),
      ),
    );
  }

  // Use this for headings (Rajdhani)
  static TextStyle get headingStyle {
    return GoogleFonts.rajdhani(
      color: text,
      fontWeight: FontWeight.bold,
    );
  }
}




