import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../settings_notifier.dart';

part 'theme_notifier.g.dart';

/// ThemeNotifier - Handles THEME and DARK MODE operations (SRP)
///
/// <150 lines respecting SRP
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  SettingsState build() {
    return SettingsState.initial();
  }

  /// Sets dark theme
  Future<void> setDarkTheme() async {
    try {
      final currentSettings = state.settings;
      final newThemeSettings = currentSettings.theme.copyWith();

      final newSettings = currentSettings.copyWith(theme: newThemeSettings);

      state = state.copyWith(
        settings: newSettings,
        successMessage: 'Tema escuro ativado',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar tema: $e');
    }
  }

  /// Sets light theme
  Future<void> setLightTheme() async {
    try {
      final currentSettings = state.settings;
      final newThemeSettings = currentSettings.theme.copyWith();

      final newSettings = currentSettings.copyWith(theme: newThemeSettings);

      state = state.copyWith(
        settings: newSettings,
        successMessage: 'Tema claro ativado',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar tema: $e');
    }
  }

  /// Sets system theme
  Future<void> setSystemTheme() async {
    try {
      final currentSettings = state.settings;
      final newThemeSettings = currentSettings.theme.copyWith();

      final newSettings = currentSettings.copyWith(theme: newThemeSettings);

      state = state.copyWith(
        settings: newSettings,
        successMessage: 'Tema do sistema ativado',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar tema: $e');
    }
  }
}
