import 'package:flutter/material.dart';

class PlantisColors {
  // Primary Colors
  static const Color primary = Color(0xFF0D945A);
  static const Color primaryLight = Color(0xFF4DB377);
  static const Color primaryDark = Color(0xFF0A7548);

  // Secondary Colors
  static const Color secondary = Color(0xFF98D8C8);
  static const Color secondaryLight = Color(0xFFC9FFF9);
  static const Color secondaryDark = Color(0xFF69A697);

  // Semantic Colors
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFFD4EFDF);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEF5E7);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFADED8);
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFDBF2FD);

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textDisabled = Color(0xFFBDC3C7);
  static const Color divider = Color(0xFFECF0F1);
  static const Color border = Color(0xFFDDE1E3);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Shadow Colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
}
