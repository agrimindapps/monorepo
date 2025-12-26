import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';

part 'theme_notifier.g.dart';

@Riverpod(keepAlive: true)
class GasometerThemeNotifier extends _$GasometerThemeNotifier {
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    return _loadTheme();
  }

  ThemeMode _loadTheme() {
    try {
      final prefs = ref.read(gasometerSharedPreferencesProvider);
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
      final prefs = ref.read(gasometerSharedPreferencesProvider);
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
