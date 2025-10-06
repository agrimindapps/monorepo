import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundLight = Color(0xFFFAFBFC);
  static const Color pendingColor = Color(0xFF9E9E9E);
  static const Color inProgressColor = Color(0xFFFF9800);
  static const Color completedColor = Color(0xFF4CAF50);
  static const Color cancelledColor = Color(0xFFF44336);
  static const Color lowPriority = Color(0xFF2196F3);
  static const Color mediumPriority = Color(0xFFFF9800);
  static const Color highPriority = Color(0xFFFF5722);
  static const Color urgentPriority = Color(0xFFE91E63);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFDDDDDD);
  static const Color borderFocus = Color(0xFF2196F3);
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color starredYellow = Color(0xFFFFC107);
  static const Color starredBorder = Color(0xFFFFB300);
  static const Color overlay = Color(0x66000000);
  static const Color overlayLight = Color(0x33000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundLight, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingColor;
      case 'inprogress':
      case 'in_progress':
        return inProgressColor;
      case 'completed':
        return completedColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return pendingColor;
    }
  }
  
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return lowPriority;
      case 'medium':
        return mediumPriority;
      case 'high':
        return highPriority;
      case 'urgent':
        return urgentPriority;
      default:
        return mediumPriority;
    }
  }
  
  static Color withOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).toInt());
  }
}
