import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/tts_settings_entity.dart';
import '../../domain/repositories/i_tts_settings_repository.dart';
import '../../domain/services/i_tts_service.dart';

part 'tts_notifier.g.dart';

@riverpod
ITTSService ttsService(TtsServiceRef ref) {
  return di.sl<ITTSService>();
}

@riverpod
ITTSSettingsRepository ttsSettingsRepository(TtsSettingsRepositoryRef ref) {
  return di.sl<ITTSSettingsRepository>();
}

@riverpod
class TtsNotifier extends _$TtsNotifier {
  late ITTSService _service;
  late ITTSSettingsRepository _repository;

  @override
  Future<TTSSettingsEntity> build() async {
    _service = ref.read(ttsServiceProvider);
    _repository = ref.read(ttsSettingsRepositoryProvider);

    // Initialize TTS service
    await _service.initialize();

    // Load settings from storage
    const userId = 'default'; // Using default user for now
    final result = await _repository.getSettings(userId);

    return result.fold(
      (failure) {
        // If loading fails, return defaults
        return TTSSettingsEntity.defaults();
      },
      (settings) {
        // Apply settings to TTS service
        _applySettingsToService(settings);
        return settings;
      },
    );
  }

  Future<void> _applySettingsToService(TTSSettingsEntity settings) async {
    try {
      await _service.setLanguage(settings.language);
      await _service.setRate(settings.rate);
      await _service.setPitch(settings.pitch);
      await _service.setVolume(settings.volume);
    } catch (e) {
      // Log error but don't fail - TTS is non-critical feature
      print('⚠️ Failed to apply TTS settings: $e');
    }
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    final currentSettings = state.value;
    if (currentSettings == null || !currentSettings.enabled) {
      return;
    }

    try {
      await _service.speak(text);
    } catch (e) {
      // TTS failed, but don't throw - just silently fail
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _service.stop();
    } catch (e) {
      // Stop failed, but don't throw
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    try {
      await _service.pause();
    } catch (e) {
      // Pause failed, but don't throw
    }
  }

  /// Resume paused speech
  Future<void> resume() async {
    try {
      await _service.resume();
    } catch (e) {
      // Resume failed, but don't throw
    }
  }

  /// Update TTS settings
  Future<void> updateSettings(TTSSettingsEntity newSettings) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Save to storage
      const userId = 'default';
      final saveResult = await _repository.saveSettings(userId, newSettings);

      return saveResult.fold((failure) => throw failure, (_) {
        // Apply new settings to TTS service
        _applySettingsToService(newSettings);
        return newSettings;
      });
    });
  }

  /// Toggle TTS enabled state
  Future<void> toggleEnabled() async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    await updateSettings(
      currentSettings.copyWith(enabled: !currentSettings.enabled),
    );
  }

  /// Update speech rate
  Future<void> updateRate(double rate) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    await updateSettings(currentSettings.copyWith(rate: rate));
  }

  /// Update pitch
  Future<void> updatePitch(double pitch) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    await updateSettings(currentSettings.copyWith(pitch: pitch));
  }

  /// Update volume
  Future<void> updateVolume(double volume) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    await updateSettings(currentSettings.copyWith(volume: volume));
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    await updateSettings(TTSSettingsEntity.defaults());
  }
}

@riverpod
Stream<TTSSpeechState> ttsStateStream(TtsStateStreamRef ref) {
  final service = ref.watch(ttsServiceProvider);
  return service.speechStateStream;
}
