import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/shared_preferences_provider.dart';

part 'theme_notifier.g.dart';

/// Theme provider for Calculei app
@riverpod
class CalculeiThemeNotifier extends _$CalculeiThemeNotifier {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    return _loadTheme();
  }

  ThemeMode _loadTheme() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final themeIndex = prefs.getInt(_themeKey);
      
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        return ThemeMode.values[themeIndex];
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;

    state = mode;

    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
