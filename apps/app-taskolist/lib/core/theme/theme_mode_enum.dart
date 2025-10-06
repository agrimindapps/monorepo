import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system;
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
  String get persistenceValue {
    return name;
  }
  static AppThemeMode fromPersistenceValue(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}