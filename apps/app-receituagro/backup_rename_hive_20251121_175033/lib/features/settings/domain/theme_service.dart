import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_service.g.dart';

/// Theme Notifier using Riverpod
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    // Default theme is system
    return ThemeMode.system;
  }

  /// Whether the current theme is dark
  bool get isDark {
    switch (state) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return false; // Default to light if system
    }
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    state = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Set specific theme mode
  void setTheme(ThemeMode mode) {
    if (state != mode) {
      state = mode;
    }
  }

  /// Get current theme icon
  IconData get themeIcon {
    return isDark ? Icons.light_mode : Icons.dark_mode;
  }
}

/// Derived provider for theme icon
@riverpod
IconData themeIcon(ThemeIconRef ref) {
  final themeMode = ref.watch(themeNotifierProvider);

  switch (themeMode) {
    case ThemeMode.dark:
      return Icons.light_mode;
    case ThemeMode.light:
      return Icons.dark_mode;
    case ThemeMode.system:
      return Icons.brightness_auto;
  }
}

/// Derived provider for isDark check
@riverpod
bool isDarkTheme(IsDarkThemeRef ref) {
  final themeMode = ref.watch(themeNotifierProvider);

  switch (themeMode) {
    case ThemeMode.dark:
      return true;
    case ThemeMode.light:
      return false;
    case ThemeMode.system:
      return false; // Default to light if system
  }
}
