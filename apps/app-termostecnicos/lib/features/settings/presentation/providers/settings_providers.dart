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
// Settings State Notifier (Riverpod 3.x with @riverpod)
// ============================================================================

@riverpod
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    return _loadSettings();
  }

  Future<AppSettings> _loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.getSettings();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (settings) => settings,
    );
  }

  /// Toggle dark/light theme
  Future<void> toggleTheme() async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(
      isDarkMode: !currentSettings.isDarkMode,
    );

    // Optimistic update
    state = AsyncValue.data(newSettings);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      final result = await repository.updateTheme(newSettings.isDarkMode);

      result.fold(
        (failure) {
          // Revert on error
          state = AsyncValue.data(currentSettings);
          throw Exception(failure.message);
        },
        (_) {
          // Success - state already updated
        },
      );
    } catch (error) {
      // Revert on error
      state = AsyncValue.data(currentSettings);
      rethrow;
    }
  }

  /// Update TTS (Text-to-Speech) settings
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

    // Optimistic update
    state = AsyncValue.data(newSettings);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      final result = await repository.updateTTSSettings(
        speed: speed,
        pitch: pitch,
        volume: volume,
        language: language,
      );

      result.fold(
        (failure) {
          // Revert on error
          state = AsyncValue.data(currentSettings);
          throw Exception(failure.message);
        },
        (_) {
          // Success - state already updated
        },
      );
    } catch (error) {
      // Revert on error
      state = AsyncValue.data(currentSettings);
      rethrow;
    }
  }

  /// Refresh settings from repository
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadSettings());
  }
}
