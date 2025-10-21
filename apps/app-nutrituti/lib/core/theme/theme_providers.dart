import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Light theme provider
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
  );
});

// Dark theme provider
final darkThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
  );
});

// Theme mode notifier for managing theme state
class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false = light, true = dark

  void toggleTheme() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}

// Theme mode provider
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

// Current theme mode provider
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(themeNotifierProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});
