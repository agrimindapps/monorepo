// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fnutrituti/core/themes/manager.dart';

class TodoistColors {
  // Cores de fundo
  static Color get backgroundColor => ThemeManager().isDark.value
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFF7F7F7);

  static Color get surfaceColor =>
      ThemeManager().isDark.value ? const Color(0xFF2D2D2D) : Colors.white;

  static Color get cardColor =>
      ThemeManager().isDark.value ? const Color(0xFF2D2D2D) : Colors.white;

  // Cores primárias
  static Color get primaryColor => ThemeManager().isDark.value
      ? const Color(0xFF4CAF50)
      : const Color(0xFF4CAF50);

  static Color get secondaryColor => ThemeManager().isDark.value
      ? const Color(0xFF3A5998)
      : const Color(0xFF3A5998);

  // Cores de texto
  static Color get textColor =>
      ThemeManager().isDark.value ? Colors.white : Colors.black87;

  static Color get subtitleColor =>
      ThemeManager().isDark.value ? Colors.grey[400]! : Colors.grey[600]!;

  static Color get hintColor => Colors.grey[500]!;

  // Cores de borda
  static Color get borderColor =>
      ThemeManager().isDark.value ? Colors.grey.shade800 : Colors.grey.shade200;

  static Color get dividerColor =>
      ThemeManager().isDark.value ? Colors.grey.shade800 : Colors.grey.shade300;

  // Cores específicas do app
  static Color get appBarColor => ThemeManager().isDark.value
      ? const Color(0xFF2D2D2D)
      : const Color(0xFF4CAF50);

  static Color get appBarTextColor => Colors.white;

  static Color get taskItemColor =>
      ThemeManager().isDark.value ? const Color(0xFF2D2D2D) : Colors.white;

  static Color get completedTaskColor =>
      ThemeManager().isDark.value ? Colors.grey.shade700 : Colors.grey.shade200;

  // Cores de estado
  static Color get successColor => const Color(0xFF4CAF50);

  static Color get errorColor => ThemeManager().isDark.value
      ? const Color(0xFFEF5350)
      : const Color(0xFFD32F2F);

  static Color get warningColor => ThemeManager().isDark.value
      ? const Color(0xFFFF9800)
      : const Color(0xFFFF9800);

  // Cores de prioridade para tarefas
  static Color get highPriorityColor => const Color(0xFFFF5722);
  static Color get mediumPriorityColor => const Color(0xFFFF9800);
  static Color get lowPriorityColor => const Color(0xFF4CAF50);

  // Background themes integration (mantém compatibilidade)
  static Color getBackgroundThemeColor(int themeIndex) {
    final backgroundColors = [
      const Color(0xFFE8F5E8), // defaultGreen
      const Color(0xFFE3F2FD), // lightBlue
      const Color(0xFFF3E5F5), // softPurple
      const Color(0xFFFFF3E0), // warmOrange
      const Color(0xFFF5F5F5), // coolGray
      const Color(0xFFFCE4EC), // rosePink
      const Color(0xFFE0F2F1), // mintGreen
      const Color(0xFFEDE7F6), // lavender
      const Color(0xFFFFF8E1), // peach
      const Color(0xFFE1F5FE), // skyBlue
    ];

    if (themeIndex >= 0 && themeIndex < backgroundColors.length) {
      return backgroundColors[themeIndex];
    }
    return backgroundColors[0]; // defaultGreen
  }

  static Color getBackgroundThemePrimaryColor(int themeIndex) {
    final primaryColors = [
      const Color(0xFF4CAF50), // defaultGreen
      const Color(0xFF2196F3), // lightBlue
      const Color(0xFF9C27B0), // softPurple
      const Color(0xFFFF9800), // warmOrange
      const Color(0xFF607D8B), // coolGray
      const Color(0xFFE91E63), // rosePink
      const Color(0xFF009688), // mintGreen
      const Color(0xFF673AB7), // lavender
      const Color(0xFFFF5722), // peach
      const Color(0xFF03A9F4), // skyBlue
    ];

    if (themeIndex >= 0 && themeIndex < primaryColors.length) {
      return primaryColors[themeIndex];
    }
    return primaryColors[0]; // defaultGreen
  }
}
