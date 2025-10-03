import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_notifier.g.dart';

/// Notifier para gerenciamento de tema do app ReceitaAgro
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadThemeFromPreferences();
    return ThemeMode.system;
  }

  /// Load theme from shared preferences
  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      if (savedTheme != null) {
        final themeMode = _parseThemeMode(savedTheme);
        state = themeMode;
      }
    } catch (e) {
      // Fallback to system theme if there's an error
      state = ThemeMode.system;
    }
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Set theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state == themeMode) return;

    state = themeMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = _themeToString(themeMode);
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      // Handle error silently - theme change will still work for current session
    }
  }

  /// Convert theme mode to string
  String _themeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newTheme);
  }

  /// Check if current theme is dark
  bool get isDarkMode => state == ThemeMode.dark;

  /// Check if current theme is light
  bool get isLightMode => state == ThemeMode.light;

  /// Check if current theme follows system
  bool get isSystemMode => state == ThemeMode.system;
}
