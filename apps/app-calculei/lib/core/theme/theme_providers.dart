import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

/// Light theme provider
@riverpod
ThemeData lightTheme(LightThemeRef ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue, // Calculadoras = azul
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

/// Dark theme provider
@riverpod
ThemeData darkTheme(DarkThemeRef ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

/// Theme mode notifier (dark mode boolean state)
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  bool build() {
    return false; // false = light, true = dark
  }

  void toggleTheme() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}

/// Current theme mode provider
@riverpod
ThemeMode currentThemeMode(CurrentThemeModeRef ref) {
  final isDark = ref.watch(themeModeNotifierProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
}
