import 'package:flutter/material.dart';

/// Cores específicas do Calculei (foco em cálculos agrícolas)
class CalculeiColors {
  static const Color primary = Color(0xFF4CAF50);        // Green
  static const Color primaryLight = Color(0xFF81C784);   // Light green
  static const Color primaryDark = Color(0xFF388E3C);    // Dark green
  static const Color secondary = Color(0xFF2196F3);      // Blue
  static const Color secondaryLight = Color(0xFF64B5F6); // Light blue
  static const Color secondaryDark = Color(0xFF1976D2);  // Dark blue
  static const Color accent = Color(0xFFFF9800);         // Orange
  static const Color accentLight = Color(0xFFFFB74D);    // Light orange
  static const Color accentDark = Color(0xFFF57C00);     // Dark orange
  
  static const Color efficiency = Color(0xFF4CAF50);     // Green for good efficiency
  static const Color warning = Color(0xFFFF9800);        // Amber for warnings
  static const Color danger = Color(0xFFF44336);         // Red for alerts
  static const Color info = Color(0xFF2196F3);           // Blue for information
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
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
  
  static const Color error = Color(0xFFF44336);         // Red for errors
  static const Color errorLight = Color(0xFFEF5350);    // Light red
  
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, errorLight],
  );
  
  static const List<Color> chartColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
  ];
  
  static Color getPrimaryShade(int shade) {
    switch (shade) {
      case 50: return const Color(0xFFE8F5E9);
      case 100: return const Color(0xFFC8E6C9);
      case 200: return const Color(0xFFA5D6A7);
      case 300: return const Color(0xFF81C784);
      case 400: return const Color(0xFF66BB6A);
      case 500: return primary;
      case 600: return const Color(0xFF43A047);
      case 700: return const Color(0xFF388E3C);
      case 800: return const Color(0xFF2E7D32);
      case 900: return const Color(0xFF1B5E20);
      default: return primary;
    }
  }
  
  static Color getSecondaryShade(int shade) {
    switch (shade) {
      case 50: return const Color(0xFFE3F2FD);
      case 100: return const Color(0xFFBBDEFB);
      case 200: return const Color(0xFF90CAF9);
      case 300: return const Color(0xFF64B5F6);
      case 400: return const Color(0xFF42A5F5);
      case 500: return secondary;
      case 600: return const Color(0xFF1E88E5);
      case 700: return const Color(0xFF1976D2);
      case 800: return const Color(0xFF1565C0);
      case 900: return const Color(0xFF0D47A1);
      default: return secondary;
    }
  }

  /// Cor de fundo padrão das páginas
  static Color getPageBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color(0xFF1C1C1E) // Cor escura personalizada
        : const Color(0xFFF0F2F5); // Cor cinza clara para modo claro
  }
}
