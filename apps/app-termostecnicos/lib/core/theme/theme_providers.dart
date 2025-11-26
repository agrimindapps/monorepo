import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../themes/light_theme.dart' as light;
import '../themes/dark_theme.dart' as dark;

part 'theme_providers.g.dart';

/// Provider for light theme
@riverpod
ThemeData lightTheme(Ref ref) {
  return light.lightTheme;
}

/// Provider for dark theme
@riverpod
ThemeData darkTheme(Ref ref) {
  return dark.darkTheme;
}

/// Provider for current theme mode
@riverpod
ThemeMode themeMode(Ref ref) {
  // TODO: Read from settings - for now default to system
  return ThemeMode.system;
}

/// Provider for current theme mode (alias for themeMode)
@riverpod
ThemeMode currentThemeMode(Ref ref) {
  return ref.watch(themeModeProvider);
}

/// Provider for current active theme data (convenience)
@riverpod
ThemeData currentTheme(Ref ref) {
  final themeMode = ref.watch(currentThemeModeProvider);
  return themeMode == ThemeMode.dark
      ? ref.watch(darkThemeProvider)
      : ref.watch(lightThemeProvider);
}
