import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/settings_model.dart';

part 'settings_local_datasource.g.dart';

abstract class LocalSettingsDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
  Future<void> clearSettings();
}

class SettingsLocalDataSource implements LocalSettingsDataSource {
  static const String _settingsKey = 'app_settings';

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        return SettingsModel.fromEntity(SettingsModel.fromJson({}));
      }

      final Map<String, dynamic> json = jsonDecode(settingsJson);
      return SettingsModel.fromJson(json);
    } catch (e) {
      return SettingsModel.fromEntity(SettingsModel.fromJson({}));
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      throw Exception('Erro ao salvar configurações: $e');
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
    } catch (e) {
      throw Exception('Erro ao limpar configurações: $e');
    }
  }
}

@riverpod
LocalSettingsDataSource localSettingsDataSource(Ref ref) {
  return SettingsLocalDataSource();
}
