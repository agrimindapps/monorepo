import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  // Converter para ThemeMode do Flutter
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Converter de ThemeMode do Flutter
  static AppThemeMode fromThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }

  // Nome localizado para UI
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Escuro';
      case AppThemeMode.system:
        return 'Sistema';
    }
  }

  // Ícone para UI
  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_brightness;
    }
  }

  // Descrição para UI
  String get description {
    switch (this) {
      case AppThemeMode.light:
        return 'Interface clara';
      case AppThemeMode.dark:
        return 'Interface escura';
      case AppThemeMode.system:
        return 'Seguir configuração do sistema';
    }
  }

  // Valor para persistência
  String get persistenceValue {
    return name;
  }

  // Criar a partir do valor de persistência
  static AppThemeMode fromPersistenceValue(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}