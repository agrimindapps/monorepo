import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/features/settings/data/models/settings_model.dart';

/// Settings Local Data Source
@injectable
class SettingsLocalDataSource {
  static const String _settingsBoxName = 'app_settings';
  final SharedPreferences _prefs;

  const SettingsLocalDataSource(this._prefs);

  Box<SettingsModel> get _settingsBox => Hive.box<SettingsModel>(_settingsBoxName);

  static Future<void> initialize() async {
    await Hive.openBox<SettingsModel>(_settingsBoxName);
  }

  /// Save settings
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      await _settingsBox.put('current', settings);
    } catch (e) {
      throw CacheException('Failed to save settings: $e');
    }
  }

  /// Get settings
  Future<SettingsModel?> getSettings() async {
    try {
      return _settingsBox.get('current');
    } catch (e) {
      throw CacheException('Failed to get settings: $e');
    }
  }

  /// Get default settings
  Future<SettingsModel> getDefaultSettings(String userId) async {
    return SettingsModel(
      userId: userId,
      theme: AppThemeModel.system,
      language: 'pt_BR',
      lastUpdated: DateTime.now(),
    );
  }

  /// Save quick preference
  Future<void> saveQuickPreference(String key, dynamic value) async {
    try {
      if (value is String) await _prefs.setString(key, value);
      else if (value is bool) await _prefs.setBool(key, value);
      else if (value is int) await _prefs.setInt(key, value);
      else if (value is double) await _prefs.setDouble(key, value);
    } catch (e) {
      throw CacheException('Failed to save quick preference: $e');
    }
  }

  /// Get quick preference
  T? getQuickPreference<T>(String key) {
    try {
      return _prefs.get(key) as T?;
    } catch (e) {
      return null;
    }
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    try {
      await _settingsBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear settings: $e');
    }
  }
}