import 'package:core/core.dart' hide Column;

import '../entities/tts_settings_entity.dart';

abstract class ITTSSettingsRepository {
  /// Get TTS settings for user
  Future<Either<Failure, TTSSettingsEntity>> getSettings(String userId);

  /// Save TTS settings for user
  Future<Either<Failure, void>> saveSettings(
    String userId,
    TTSSettingsEntity settings,
  );

  /// Reset settings to default values
  Future<Either<Failure, void>> resetToDefault(String userId);
}
