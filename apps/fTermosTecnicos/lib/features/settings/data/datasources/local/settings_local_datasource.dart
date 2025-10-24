import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_settings_model.dart';

/// Interface for settings local data source
abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getSettings();
  Future<void> saveSettings(AppSettingsModel settings);
  Future<void> updateTheme(bool isDarkMode);
  Future<void> updateTTSSettings({
    double? speed,
    double? pitch,
    double? volume,
    String? language,
  });
}

/// Implementation of settings local data source using SharedPreferences
@LazySingleton(as: SettingsLocalDataSource)
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _prefs;

  // Keys for SharedPreferences
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyTtsSpeed = 'tts_speech_rate';
  static const String _keyTtsPitch = 'tts_pitch';
  static const String _keyTtsVolume = 'tts_volume';
  static const String _keyTtsLanguage = 'tts_language';

  SettingsLocalDataSourceImpl(this._prefs);

  @override
  Future<AppSettingsModel> getSettings() async {
    try {
      final isDarkMode = _prefs.getBool(_keyThemeMode) ?? false;
      final ttsSpeed = _prefs.getDouble(_keyTtsSpeed) ?? 0.5;
      final ttsPitch = _prefs.getDouble(_keyTtsPitch) ?? 1.0;
      final ttsVolume = _prefs.getDouble(_keyTtsVolume) ?? 1.0;
      final ttsLanguage = _prefs.getString(_keyTtsLanguage) ?? 'pt-BR';

      return AppSettingsModel(
        isDarkMode: isDarkMode,
        ttsSpeed: ttsSpeed,
        ttsPitch: ttsPitch,
        ttsVolume: ttsVolume,
        ttsLanguage: ttsLanguage,
      );
    } catch (e) {
      throw Exception('Failed to get settings from local storage: $e');
    }
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    try {
      await _prefs.setBool(_keyThemeMode, settings.isDarkMode);
      await _prefs.setDouble(_keyTtsSpeed, settings.ttsSpeed);
      await _prefs.setDouble(_keyTtsPitch, settings.ttsPitch);
      await _prefs.setDouble(_keyTtsVolume, settings.ttsVolume);
      await _prefs.setString(_keyTtsLanguage, settings.ttsLanguage);
    } catch (e) {
      throw Exception('Failed to save settings to local storage: $e');
    }
  }

  @override
  Future<void> updateTheme(bool isDarkMode) async {
    try {
      await _prefs.setBool(_keyThemeMode, isDarkMode);
    } catch (e) {
      throw Exception('Failed to update theme: $e');
    }
  }

  @override
  Future<void> updateTTSSettings({
    double? speed,
    double? pitch,
    double? volume,
    String? language,
  }) async {
    try {
      if (speed != null) {
        await _prefs.setDouble(_keyTtsSpeed, speed);
      }
      if (pitch != null) {
        await _prefs.setDouble(_keyTtsPitch, pitch);
      }
      if (volume != null) {
        await _prefs.setDouble(_keyTtsVolume, volume);
      }
      if (language != null) {
        await _prefs.setString(_keyTtsLanguage, language);
      }
    } catch (e) {
      throw Exception('Failed to update TTS settings: $e');
    }
  }
}
