import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_notifier.g.dart';

/// Key for storing theme mode preference
const String _themePreferenceKey = 'app_theme_mode';

/// Theme mode notifier for managing app theme
/// Persists user preference using SharedPreferences
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const ThemeMode _defaultTheme = ThemeMode.system;

  @override
  ThemeMode build() {
    _loadThemePreference();
    return _defaultTheme;
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themePreferenceKey);

      if (themeModeString != null) {
        final themeMode = _parseThemeMode(themeModeString);
        state = themeMode;
      }
    } catch (e) {
      // If loading fails, use default theme
      debugPrint('[ThemeNotifier] Error loading theme preference: $e');
    }
  }

  /// Set theme mode and persist to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, mode.name);
      state = mode;
    } catch (e) {
      debugPrint('[ThemeNotifier] Error saving theme preference: $e');
    }
  }

  /// Parse ThemeMode from string
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return _defaultTheme;
    }
  }

  /// Check if current theme is dark
  bool get isDarkMode {
    return state == ThemeMode.dark;
  }

  /// Check if current theme is light
  bool get isLightMode {
    return state == ThemeMode.light;
  }

  /// Check if current theme is system
  bool get isSystemMode {
    return state == ThemeMode.system;
  }
}
