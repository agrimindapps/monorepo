import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_theme.dart';
import '../../domain/usecases/update_tts_settings.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';

part 'settings_providers.g.dart';

// ============================================================================
// Data Source Provider
// ============================================================================

@riverpod
SettingsLocalDataSource settingsLocalDataSource(
  SettingsLocalDataSourceRef ref,
) {
  return ref.watch(getItProvider).get<SettingsLocalDataSource>();
}

// ============================================================================
// Repository Provider
// ============================================================================

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return ref.watch(getItProvider).get<SettingsRepository>();
}

// ============================================================================
// Use Case Providers
// ============================================================================

@riverpod
GetSettings getSettingsUseCase(GetSettingsUseCaseRef ref) {
  return GetSettings(ref.watch(settingsRepositoryProvider));
}

@riverpod
UpdateTheme updateThemeUseCase(UpdateThemeUseCaseRef ref) {
  return UpdateTheme(ref.watch(settingsRepositoryProvider));
}

@riverpod
UpdateTTSSettings updateTTSSettingsUseCase(UpdateTTSSettingsUseCaseRef ref) {
  return UpdateTTSSettings(ref.watch(settingsRepositoryProvider));
}

// ============================================================================
// Settings State Notifier
// ============================================================================

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final useCase = ref.read(getSettingsUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (settings) => settings,
    );
  }

  /// Toggle between dark and light theme
  Future<void> toggleTheme() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentSettings = await future;
      final newIsDarkMode = !currentSettings.isDarkMode;

      final useCase = ref.read(updateThemeUseCaseProvider);
      final result = await useCase(newIsDarkMode);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => currentSettings.copyWith(isDarkMode: newIsDarkMode),
      );
    });
  }

  /// Update TTS speed
  Future<void> updateTTSSpeed(double speed) async {
    state = await AsyncValue.guard(() async {
      final currentSettings = await future;

      final useCase = ref.read(updateTTSSettingsUseCaseProvider);
      final params = UpdateTTSSettingsParams(speed: speed);
      final result = await useCase(params);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => currentSettings.copyWith(ttsSpeed: speed),
      );
    });
  }

  /// Update TTS pitch
  Future<void> updateTTSPitch(double pitch) async {
    state = await AsyncValue.guard(() async {
      final currentSettings = await future;

      final useCase = ref.read(updateTTSSettingsUseCaseProvider);
      final params = UpdateTTSSettingsParams(pitch: pitch);
      final result = await useCase(params);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => currentSettings.copyWith(ttsPitch: pitch),
      );
    });
  }

  /// Update TTS volume
  Future<void> updateTTSVolume(double volume) async {
    state = await AsyncValue.guard(() async {
      final currentSettings = await future;

      final useCase = ref.read(updateTTSSettingsUseCaseProvider);
      final params = UpdateTTSSettingsParams(volume: volume);
      final result = await useCase(params);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => currentSettings.copyWith(ttsVolume: volume),
      );
    });
  }

  /// Update TTS language
  Future<void> updateTTSLanguage(String language) async {
    state = await AsyncValue.guard(() async {
      final currentSettings = await future;

      final useCase = ref.read(updateTTSSettingsUseCaseProvider);
      final params = UpdateTTSSettingsParams(language: language);
      final result = await useCase(params);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => currentSettings.copyWith(ttsLanguage: language),
      );
    });
  }
}

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for current theme mode
@riverpod
ThemeMode themeMode(ThemeModeRef ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);

  return settingsAsync.when(
    data: (settings) => settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
}

/// Provider for checking if dark mode is enabled
@riverpod
bool isDarkMode(IsDarkModeRef ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);

  return settingsAsync.maybeWhen(
    data: (settings) => settings.isDarkMode,
    orElse: () => false,
  );
}

/// Provider for TTS speed
@riverpod
double ttsSpeed(TtsSpeedRef ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);

  return settingsAsync.maybeWhen(
    data: (settings) => settings.ttsSpeed,
    orElse: () => 0.5,
  );
}

/// Provider for TTS pitch
@riverpod
double ttsPitch(TtsPitchRef ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);

  return settingsAsync.maybeWhen(
    data: (settings) => settings.ttsPitch,
    orElse: () => 1.0,
  );
}

/// Provider for TTS volume
@riverpod
double ttsVolume(TtsVolumeRef ref) {
  final settingsAsync = ref.watch(settingsNotifierProvider);

  return settingsAsync.maybeWhen(
    data: (settings) => settings.ttsVolume,
    orElse: () => 1.0,
  );
}
