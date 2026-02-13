import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ───────────────────────────────────────────────
//  Color Palette
// ───────────────────────────────────────────────
class Palette {
  Palette._();

  // Core
  static const Color background = Color(0xFFFBF7E3);
  static const Color surface = Color(0xFFFFF9EC);
  static const Color white = Color(0xFFF0ECE3);
  static const Color black = Color(0xFF1A1A1A);

  // Brand
  static const Color primary = Color(0xFF87A848);      // matcha green
  static const Color secondary = Color(0xFF461707);     // dark brown
  static const Color tertiary = Color(0xFF3A1078);

  // Convenience
  static const Color accent = Color(0xFF87A848);
  static const Color green = Color(0xFF4ADE80);
  static const Color blue = Color(0xFF3795BD);
  static const Color pink = Color(0xFFF472B6);

  // Semantic
  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF3795BD);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF444444);
  static const Color textMuted = Color(0xFF777777);

  // Border
  static const Color border = Color(0xFF1A1A1A);
}

// ───────────────────────────────────────────────
//  App Theme
// ───────────────────────────────────────────────
class GlassTheme {
  GlassTheme._();

  static TextTheme _textTheme() {
    return TextTheme(
      headlineLarge: GoogleFonts.lexend(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: Palette.textPrimary, letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.lexend(
        fontSize: 22, fontWeight: FontWeight.w600, color: Palette.textPrimary,
      ),
      titleLarge: GoogleFonts.lexend(
        fontSize: 18, fontWeight: FontWeight.w600, color: Palette.textPrimary,
      ),
      titleMedium: GoogleFonts.lexend(
        fontSize: 16, fontWeight: FontWeight.w600, color: Palette.textPrimary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15, fontWeight: FontWeight.w500,
        color: Palette.textPrimary, height: 1.5,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w500,
        color: Palette.textSecondary, height: 1.5,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: Palette.textPrimary, letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: Palette.textMuted, letterSpacing: 0.3,
      ),
    );
  }

  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Palette.background,
      colorScheme: const ColorScheme.light(
        primary: Palette.primary,
        secondary: Palette.secondary,
        surface: Palette.surface,
        error: Palette.error,
        onPrimary: Colors.white,
        onSurface: Palette.textPrimary,
        outline: Palette.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Palette.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lexend(
          color: Palette.textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Palette.textPrimary),
      ),
      textTheme: _textTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Palette.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.border, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.border, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.border, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.error, width: 2.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.error, width: 2.5),
        ),
        labelStyle: GoogleFonts.dmSans(
          color: Palette.textSecondary, fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Palette.border, width: 1.5),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Palette.textPrimary,
        selectionHandleColor: Palette.textPrimary,
      ),
    );
  }

  // Backward compat
  static ThemeData get lightTheme => buildTheme();
  static ThemeData get darkTheme => buildTheme();
}
