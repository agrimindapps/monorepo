import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'minigames_theme.dart';

part 'theme_providers.g.dart';

/// Light theme provider
@riverpod
ThemeData lightTheme(Ref ref) {
  return MinigamesTheme.lightTheme;
}

/// Dark theme provider
@riverpod
ThemeData darkTheme(Ref ref) {
  return MinigamesTheme.darkTheme;
}

/// Theme mode notifier with persistence (supports light/dark/system)
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const String _themeKey = 'theme_mode_minigames';

  @override
  ThemeMode build() {
    // Load theme asynchronously after initialization
    _loadTheme();
    return ThemeMode.system; // Default to system
  }

  /// Loads theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        state = ThemeMode.values[themeIndex];
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
      await prefs.setInt(_themeKey, state.index);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving theme preference: $e');
      }
    }
  }

  /// Sets theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await _saveTheme();
  }

  /// Toggles between light and dark theme (ignoring system)
  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme();
  }
}

/// Current theme mode provider
@riverpod
ThemeMode currentThemeMode(Ref ref) {
  return ref.watch(themeModeProvider);
}
