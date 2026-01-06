import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

part 'theme_providers.g.dart';

/// Light theme provider
@riverpod
ThemeData lightTheme(Ref ref) {
  return AppTheme.lightTheme;
}

/// Dark theme provider
@riverpod
ThemeData darkTheme(Ref ref) {
  return AppTheme.darkTheme;
}

/// Theme mode notifier with persistence (dark mode boolean state)
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const String _themeKey = 'theme_dark_mode_calculei';

  @override
  bool build() {
    // Load theme asynchronously after initialization
    _loadTheme();
    return false; // Default: false = light, true = dark
  }

  /// Loads theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool(_themeKey);
      
      if (savedTheme != null) {
        state = savedTheme;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading theme preference: $e');
      }
    }
  }

  /// Saves theme preference to SharedPreferences
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, state);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving theme preference: $e');
      }
    }
  }

  /// Toggles between light and dark theme
  Future<void> toggleTheme() async {
    state = !state;
    await _saveTheme();
  }

  /// Sets dark mode explicitly
  Future<void> setDarkMode(bool isDark) async {
    state = isDark;
    await _saveTheme();
  }
}

/// Current theme mode provider
@riverpod
ThemeMode currentThemeMode(Ref ref) {
  final isDark = ref.watch(themeModeProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
}
