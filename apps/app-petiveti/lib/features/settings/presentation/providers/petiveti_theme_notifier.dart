import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'petiveti_theme_notifier.g.dart';

/// Provider dedicado para gerenciamento de tema do PetiVeti
/// Sincroniza com SharedPreferences para persistência
@riverpod
class PetiVetiTheme extends _$PetiVetiTheme {
  static const String _themeKey = 'theme_mode_petiveti';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
    } else {
      // Fallback: tenta ler do formato antigo (darkMode boolean)
      final darkMode = prefs.getBool('settings_dark_mode');
      if (darkMode != null) {
        state = darkMode ? ThemeMode.dark : ThemeMode.light;
        // Migra para novo formato
        await prefs.setString(_themeKey, state.toString());
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }

  /// Ativa modo escuro
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Ativa modo claro
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Ativa modo sistema
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Toggle entre claro e escuro (ignora system)
  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  /// Atualiza baseado em boolean (para compatibilidade com settings existente)
  Future<void> updateFromDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

/// Provider derivado para verificar se está no modo escuro
@riverpod
bool petiVetiIsDarkMode(Ref ref) {
  final themeMode = ref.watch(petiVetiThemeProvider);
  return themeMode == ThemeMode.dark;
}
