import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

// Light theme provider - Tema colorido para jogos
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,  // Games = roxo/colorido
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
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    ),
  );
});

// Theme mode notifier using Riverpod 3.0
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  bool build() => false; // false = light, true = dark

  void toggleTheme() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}

final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(themeProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});
