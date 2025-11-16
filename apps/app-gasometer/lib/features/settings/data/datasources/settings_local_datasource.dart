import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

/// Local data source for settings using SharedPreferences
///
/// Handles persistence of app settings
class SettingsLocalDataSource {
  final SharedPreferences _prefs;

  static const String _keyPrefix = 'settings_';
  static const String _keyIsDarkTheme = '${_keyPrefix}isDarkTheme';
  static const String _keyNotifications = '${_keyPrefix}notificationsEnabled';
  static const String _keySoundEnabled = '${_keyPrefix}soundEnabled';
  static const String _keyLanguage = '${_keyPrefix}language';
  static const String _keyDistanceUnit = '${_keyPrefix}distanceUnit';
  static const String _keyVolumeUnit = '${_keyPrefix}volumeUnit';
  static const String _keyCurrency = '${_keyPrefix}currency';
  static const String _keyMaintenanceReminder =
      '${_keyPrefix}maintenanceReminderDays';
  static const String _keyAutoBackup = '${_keyPrefix}autoBackupEnabled';
  static const String _keyAnalytics = '${_keyPrefix}analyticsEnabled';

  SettingsLocalDataSource(this._prefs);

  Future<SettingsModel> getSettings() async {
    return SettingsModel(
      isDarkTheme: _prefs.getBool(_keyIsDarkTheme) ?? false,
      notificationsEnabled: _prefs.getBool(_keyNotifications) ?? true,
      soundEnabled: _prefs.getBool(_keySoundEnabled) ?? true,
      language: _prefs.getString(_keyLanguage) ?? 'pt-BR',
      distanceUnit: _prefs.getString(_keyDistanceUnit) ?? 'km',
      volumeUnit: _prefs.getString(_keyVolumeUnit) ?? 'liters',
      currency: _prefs.getString(_keyCurrency) ?? 'BRL',
      maintenanceReminderDays: _prefs.getInt(_keyMaintenanceReminder) ?? 7,
      autoBackupEnabled: _prefs.getBool(_keyAutoBackup) ?? true,
      analyticsEnabled: _prefs.getBool(_keyAnalytics) ?? true,
    );
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await Future.wait([
      _prefs.setBool(_keyIsDarkTheme, settings.isDarkTheme),
      _prefs.setBool(_keyNotifications, settings.notificationsEnabled),
      _prefs.setBool(_keySoundEnabled, settings.soundEnabled),
      _prefs.setString(_keyLanguage, settings.language),
      _prefs.setString(_keyDistanceUnit, settings.distanceUnit),
      _prefs.setString(_keyVolumeUnit, settings.volumeUnit),
      _prefs.setString(_keyCurrency, settings.currency),
      _prefs.setInt(_keyMaintenanceReminder, settings.maintenanceReminderDays),
      _prefs.setBool(_keyAutoBackup, settings.autoBackupEnabled),
      _prefs.setBool(_keyAnalytics, settings.analyticsEnabled),
    ]);
  }

  Future<void> clearSettings() async {
    final keys = [
      _keyIsDarkTheme,
      _keyNotifications,
      _keySoundEnabled,
      _keyLanguage,
      _keyDistanceUnit,
      _keyVolumeUnit,
      _keyCurrency,
      _keyMaintenanceReminder,
      _keyAutoBackup,
      _keyAnalytics,
    ];

    await Future.wait(keys.map((key) => _prefs.remove(key)));
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final fullKey = '$_keyPrefix$key';
    if (value is bool) {
      await _prefs.setBool(fullKey, value);
    } else if (value is int) {
      await _prefs.setInt(fullKey, value);
    } else if (value is String) {
      await _prefs.setString(fullKey, value);
    }
  }
}
