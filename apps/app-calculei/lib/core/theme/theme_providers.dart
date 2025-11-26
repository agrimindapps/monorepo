import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
ThemeMode currentThemeMode(Ref ref) {
  final isDark = ref.watch(themeModeProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
}
