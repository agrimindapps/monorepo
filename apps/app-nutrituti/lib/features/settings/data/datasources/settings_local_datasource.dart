import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/settings_entity.dart';

/// Local datasource for settings using SharedPreferences
class SettingsLocalDataSource {
  final SharedPreferences _prefs;
  static const String _settingsKey = 'nutrituti_settings';

  const SettingsLocalDataSource(this._prefs);

  Future<SettingsEntity> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) {
      return const SettingsEntity();
    }
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SettingsEntity.fromJson(json);
  }

  Future<void> saveSettings(SettingsEntity settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }

  Future<void> clearSettings() async {
    await _prefs.remove(_settingsKey);
  }

  Stream<SettingsEntity> watchSettings() async* {
    yield await getSettings();
  }
}
