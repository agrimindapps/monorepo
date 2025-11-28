import 'dart:convert';

import 'package:core/core.dart';

import '../models/settings_model.dart';

/// Local data source for settings using SharedPreferences
abstract class SettingsLocalDataSource {
  Future<Either<Failure, SettingsModel>> getSettings();
  Future<Either<Failure, SettingsModel>> saveSettings(SettingsModel settings);
  Future<Either<Failure, void>> clearSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _settingsKey = 'petiveti_app_settings';

  @override
  Future<Either<Failure, SettingsModel>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        // Return default settings
        return const Right(
          SettingsModel(
            id: 'default',
            darkMode: false,
            notificationsEnabled: true,
            language: 'pt_BR',
            soundsEnabled: true,
            vibrationEnabled: true,
            reminderHoursBefore: 24,
            autoSync: true,
          ),
        );
      }

      final json = jsonDecode(settingsJson) as Map<String, dynamic>;
      final settings = SettingsModel.fromJson(json);
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar configurações: $e'));
    }
  }

  @override
  Future<Either<Failure, SettingsModel>> saveSettings(
    SettingsModel settings,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar configurações: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar configurações: $e'));
    }
  }
}
