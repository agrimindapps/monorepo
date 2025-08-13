// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/themes/manager.dart';

class PlantasColors {
  // Cores de fundo
  static Color get backgroundColor => ThemeManager().isDark.value
      ? const Color(0xFF2D2D2D)
      : const Color(0xFFF5F5F5);

  static Color get surfaceColor =>
      ThemeManager().isDark.value ? const Color(0xFF1A1A1A) : Colors.white;

  static Color get cardColor =>
      ThemeManager().isDark.value ? const Color(0xFF363636) : Colors.white;

  // Cores primárias
  static Color get primaryColor => ThemeManager().isDark.value
      ? const Color(0xFF1A9B95)
      : const Color(0xFF20B2AA);

  // Cores de texto
  static Color get textColor =>
      ThemeManager().isDark.value ? Colors.white : Colors.black87;

  static Color get subtitleColor =>
      ThemeManager().isDark.value ? Colors.grey[400]! : Colors.grey[600]!;

  // Cores de borda
  static Color get borderColor =>
      ThemeManager().isDark.value ? Colors.grey.shade800 : Colors.grey.shade200;

  // Cores secundárias de texto
  static Color get textSecondaryColor => ThemeManager().isDark.value
      ? const Color(0xFFB0B0B0)
      : const Color(0xFF757575);

  // Cor de sombra
  static Color get shadowColor => ThemeManager().isDark.value
      ? Colors.black.withValues(alpha: 0.4)
      : Colors.grey.withValues(alpha: 0.15);

  // Cores de status
  static Color get errorColor => ThemeManager().isDark.value
      ? const Color(0xFFEF5350)
      : const Color(0xFFD32F2F);

  static Color get errorBackgroundColor => ThemeManager().isDark.value
      ? const Color(0xFF5D1E1E)
      : const Color(0xFFFFEBEE);

  static Color get errorBorderColor => ThemeManager().isDark.value
      ? const Color(0xFF8B2635)
      : const Color(0xFFFFCDD2);
}
