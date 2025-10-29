import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/theme_settings_entity.dart';

/// State class for theme settings
class ThemeState {
  final ThemeSettingsEntity settings;
  final bool isLoading;
  final String? error;

  const ThemeState({
    required this.settings,
    required this.isLoading,
    this.error,
  });

  factory ThemeState.initial() {
    return ThemeState(
      settings: ThemeSettingsEntity.defaults(),
      isLoading: false,
      error: null,
    );
  }

  ThemeState copyWith({
    ThemeSettingsEntity? settings,
    bool? isLoading,
    String? error,
  }) {
    return ThemeState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  ThemeState clearError() {
    return copyWith(error: null);
  }
}

/// Notifier for managing theme-related user settings
/// Handles dark mode and language preferences
///
/// Responsibilities:
/// - Toggle dark mode on/off
/// - Set language preference
/// - Load/save theme settings
/// - Validate theme configuration
/// - Persist to storage
///
/// State: ThemeState
/// - settings: Current ThemeSettingsEntity
/// - isLoading: Whether operations are in progress
/// - error: Error message if any
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState.initial());

  /// Toggles dark mode on/off
  ///
  /// Steps:
  /// 1. Get current state
  /// 2. Toggle isDarkTheme
  /// 3. Update state
  /// 4. Persist to storage (if needed)
  Future<void> toggleDarkMode() async {
    try {
      // Update state to loading
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.copyWith(
        isDarkTheme: !state.settings.isDarkTheme,
      );

      // TODO: Persist to storage (Hive/SharedPreferences)
      // await _persistThemeSettings(updated);

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error toggling dark mode: $e\n$stack');
      state = state.copyWith(isLoading: false, error: 'Erro ao alternar tema');
    }
  }

  /// Sets language preference
  ///
  /// Validates:
  /// - Language code is not empty
  /// - Language code is valid
  Future<void> setLanguage(String languageCode) async {
    // Validate language code
    if (languageCode.isEmpty) {
      state = state.copyWith(error: 'Código de idioma inválido');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final updated = state.settings.copyWith(language: languageCode);

      // Validate after update
      if (!updated.isValid) {
        state = state.copyWith(
          isLoading: false,
          error: 'Configurações de idioma inválidas',
        );
        return;
      }

      // TODO: Persist to storage
      // await _persistThemeSettings(updated);

      state = state.copyWith(settings: updated, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error setting language: $e\n$stack');
      state = state.copyWith(isLoading: false, error: 'Erro ao definir idioma');
    }
  }

  /// Resets theme settings to defaults
  Future<void> resetToDefaults() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final defaults = ThemeSettingsEntity.defaults();

      // TODO: Persist to storage
      // await _persistThemeSettings(defaults);

      state = state.copyWith(settings: defaults, isLoading: false);
    } catch (e, stack) {
      debugPrint('Error resetting to defaults: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao redefinir padrões',
      );
    }
  }

  /// Loads theme settings from storage
  /// Useful for app initialization
  Future<void> loadThemeSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Load from storage
      // final result = await _themeRepository.getThemeSettings();
      // result.fold(
      //   (failure) => state = state.copyWith(
      //     isLoading: false,
      //     error: failure.message,
      //   ),
      //   (settings) => state = ThemeState(
      //     settings: settings,
      //     isLoading: false,
      //     error: null,
      //   ),
      // );

      // For now, use defaults
      state = state.copyWith(isLoading: false);
    } catch (e, stack) {
      debugPrint('Error loading theme settings: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar configurações de tema',
      );
    }
  }

  // Getters for easy access

  /// Get current theme settings
  ThemeSettingsEntity get currentSettings => state.settings;

  /// Get current dark mode status
  bool get isDarkMode => state.settings.isDarkTheme;

  /// Get current language
  String get language => state.settings.language;

  /// Get human-readable language name
  String get languageDisplayName => state.settings.languageDisplayName;

  /// Check if RTL language is active
  bool get isRtl => state.settings.isRtlLanguage;

  /// Check if currently loading
  bool get isLoading => state.isLoading;

  /// Check if there's an error
  bool get hasError => state.error != null;

  /// Get error message if any
  String? get errorMessage => state.error;
}

/// Provider for theme settings
/// Use: ref.watch(themeNotifierProvider)
final themeNotifierProvider =
    StateNotifierProvider.autoDispose<ThemeNotifier, ThemeState>(
      (ref) => ThemeNotifier(),
    );
