import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import '../themes/light_theme.dart' as light;
import '../themes/dark_theme.dart' as dark;

part 'theme_providers.g.dart';

/// Provider for light theme
@riverpod
ThemeData lightTheme(LightThemeRef ref) {
  return light.lightTheme;
}

/// Provider for dark theme
@riverpod
ThemeData darkTheme(DarkThemeRef ref) {
  return dark.darkTheme;
}

/// Provider for current theme mode
@riverpod
ThemeMode currentThemeMode(CurrentThemeModeRef ref) {
  return ref.watch(themeModeProvider);
}

/// Provider for current active theme data (convenience)
@riverpod
ThemeData currentTheme(CurrentThemeRef ref) {
  final themeMode = ref.watch(currentThemeModeProvider);
  return themeMode == ThemeMode.dark
      ? ref.watch(darkThemeProvider)
      : ref.watch(lightThemeProvider);
}
