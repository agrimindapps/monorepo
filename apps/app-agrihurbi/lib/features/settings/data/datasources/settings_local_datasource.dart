import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/features/settings/data/models/settings_model.dart';
import 'package:app_agrihurbi/features/settings/domain/entities/settings_entity.dart';
import 'package:core/core.dart';

/// Settings Local Data Source
abstract class SettingsLocalDataSource {
  /// Save settings
  Future<void> saveSettings(SettingsModel settings);

  /// Get settings
  Future<SettingsModel?> getSettings();

  /// Get default settings
  Future<SettingsModel> getDefaultSettings(String userId);

  /// Save quick preference
  Future<void> saveQuickPreference(String key, dynamic value);

  /// Get quick preference
  T? getQuickPreference<T>(String key);

  /// Clear all settings
  Future<void> clearSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences _prefs;

  const SettingsLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    throw UnimplementedError('saveSettings has not been implemented');
  }

  @override
  Future<SettingsModel?> getSettings() async {
    throw UnimplementedError('getSettings has not been implemented');
  }

  @override
  Future<SettingsModel> getDefaultSettings(String userId) async {
    return SettingsModel(
      userId: userId,
      theme: AppTheme.system,
      language: 'pt_BR',
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<void> saveQuickPreference(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      }
    } catch (e) {
      throw CacheException('Failed to save quick preference: $e');
    }
  }

  @override
  T? getQuickPreference<T>(String key) {
    try {
      return _prefs.get(key) as T?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearSettings() async {
    throw UnimplementedError('clearSettings has not been implemented');
  }
}
