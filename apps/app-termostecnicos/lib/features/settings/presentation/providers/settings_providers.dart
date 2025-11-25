import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' hide Column;

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_theme.dart';
import '../../domain/usecases/update_tts_settings.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';

part 'settings_providers.g.dart';

// ============================================================================
// Data Source Provider (Simplified for now)
// ============================================================================

@riverpod
SettingsLocalDataSource settingsLocalDataSource(Ref ref) {
  // TODO: Properly inject SharedPreferences
  // For now, we'll create it directly in the repository
  throw UnimplementedError('Settings data source needs SharedPreferences');
}

// ============================================================================
// Repository Provider (Simplified)
// ============================================================================

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  // Create data source with SharedPreferences directly
  // This is a temporary solution - in production you'd inject it properly
  return SettingsRepositoryImpl(SettingsLocalDataSourceImpl(null as dynamic));
}

// ============================================================================
// Use Case Providers
// ============================================================================

@riverpod
GetSettings getSettingsUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettings(repository);
}

@riverpod
UpdateTheme updateThemeUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateTheme(repository);
}

@riverpod
UpdateTTSSettings updateTTSSettingsUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateTTSSettings(repository);
}

// ============================================================================
// Settings State Provider (Simple version for now)
// ============================================================================

final settingsProvider = StateProvider<AppSettings>((ref) {
  return const AppSettings(); // Default settings
});

// ============================================================================
// Settings Notifier Provider (will be implemented later)
// ============================================================================

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.getSettings();
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (settings) => state = AsyncValue.data(settings),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleTheme() async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(
      isDarkMode: !currentSettings.isDarkMode,
    );

    // Optimistically update UI
    state = AsyncValue.data(newSettings);

    try {
      final result = await _repository.updateTheme(newSettings.isDarkMode);
      result.fold(
        (failure) {
          // Revert on error
          state = AsyncValue.data(currentSettings);
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (_) {
          // Success - keep the new state
          state = AsyncValue.data(newSettings);
        },
      );
    } catch (error, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentSettings);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTTSSettings({
    double? speed,
    double? pitch,
    double? volume,
    String? language,
  }) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(
      ttsSpeed: speed ?? currentSettings.ttsSpeed,
      ttsPitch: pitch ?? currentSettings.ttsPitch,
      ttsVolume: volume ?? currentSettings.ttsVolume,
      ttsLanguage: language ?? currentSettings.ttsLanguage,
    );

    // Optimistically update UI
    state = AsyncValue.data(newSettings);

    try {
      final result = await _repository.updateTTSSettings(
        speed: speed,
        pitch: pitch,
        volume: volume,
        language: language,
      );
      result.fold(
        (failure) {
          // Revert on error
          state = AsyncValue.data(currentSettings);
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (_) {
          // Success - keep the new state
          state = AsyncValue.data(newSettings);
        },
      );
    } catch (error, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentSettings);
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
