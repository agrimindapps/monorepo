import 'dart:convert';

import 'package:core/core.dart';

import '../../domain/entities/tts_settings_entity.dart';
import '../../domain/repositories/i_tts_settings_repository.dart';

class TTSSettingsRepositoryImpl implements ITTSSettingsRepository {
  final SharedPreferences _sharedPreferences;

  TTSSettingsRepositoryImpl(this._sharedPreferences);

  String _getKey(String userId) => 'tts_settings_$userId';

  @override
  Future<Either<Failure, TTSSettingsEntity>> getSettings(String userId) async {
    try {
      final key = _getKey(userId);
      final jsonString = _sharedPreferences.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        // No settings saved, return defaults
        return Right(TTSSettingsEntity.defaults());
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final settings = TTSSettingsEntity.fromJson(json);

      return Right(settings);
    } catch (e) {
      return Left(
        CacheFailure('Failed to load TTS settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(
    String userId,
    TTSSettingsEntity settings,
  ) async {
    try {
      final key = _getKey(userId);
      final json = settings.toJson();
      final jsonString = jsonEncode(json);

      final success = await _sharedPreferences.setString(key, jsonString);

      if (!success) {
        return const Left(
          CacheFailure('Failed to save TTS settings to storage'),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure('Failed to save TTS settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetToDefault(String userId) async {
    try {
      final defaultSettings = TTSSettingsEntity.defaults();
      return await saveSettings(userId, defaultSettings);
    } catch (e) {
      return Left(
        CacheFailure('Failed to reset TTS settings: ${e.toString()}'),
      );
    }
  }
}
