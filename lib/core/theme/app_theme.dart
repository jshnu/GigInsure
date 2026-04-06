import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0F172A);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color alertRed = Color(0xFFEF4444);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentTeal,
        error: alertRed,
        surface: surfaceWhite,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryBlue),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primaryBlue),
        bodyLarge: TextStyle(fontSize: 16, color: primaryBlue),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),
    );
  }

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}