import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - Dark blue with purple accent
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFF9F67FA);

  // Background colors
  static const Color background = Color(0xFF050E1F);
  static const Color surfaceDark = Color(0xFF0A1628);
  static const Color cardDark = Color(0xFF0F2040);
  static const Color cardLight = Color(0xFF162849);

  // Gradient colors
  static const Color gradientStart = Color(0xFF0D1B3E);
  static const Color gradientMid = Color(0xFF1A2D5A);
  static const Color gradientEnd = Color(0xFF0A0E1A);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF607D8B);

  // Status colors
  static const Color live = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF1E88E5);

  // UI elements
  static const Color divider = Color(0xFF1A2D5A);
  static const Color shimmerBase = Color(0xFF0F2040);
  static const Color shimmerHighlight = Color(0xFF162849);
  static const Color overlay = Color(0x80000000);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [gradientStart, gradientMid, gradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardDark, cardLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient imageOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
