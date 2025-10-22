import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/enums.dart';
import '../models/high_score_model.dart';

abstract class MemoryLocalDataSource {
  Future<HighScoreModel> loadHighScore(GameDifficulty difficulty);
  Future<void> saveHighScore(HighScoreModel highScore);
  Future<Map<String, dynamic>> loadGameConfig();
  Future<void> saveGameConfig(Map<String, dynamic> config);
  Future<void> clearAllData();
}

class MemoryLocalDataSourceImpl implements MemoryLocalDataSource {
  static const String _highScorePrefix = 'memory_high_score_';
  static const String _configPrefix = 'memory_config_';

  final SharedPreferences _prefs;

  MemoryLocalDataSourceImpl(this._prefs);

  @override
  Future<HighScoreModel> loadHighScore(GameDifficulty difficulty) async {
    try {
      final key = '$_highScorePrefix${difficulty.name}';
      final jsonString = _prefs.getString(key);

      if (jsonString == null) {
        return HighScoreModel.empty;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScoreModel.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load high score: $e');
    }
  }

  @override
  Future<void> saveHighScore(HighScoreModel highScore) async {
    try {
      final key = '$_highScorePrefix${highScore.difficulty.name}';
      final jsonString = jsonEncode(highScore.toJson());
      await _prefs.setString(key, jsonString);
    } catch (e) {
      throw Exception('Failed to save high score: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> loadGameConfig() async {
    try {
      final config = <String, dynamic>{};

      config['soundEnabled'] = _prefs.getBool('${_configPrefix}soundEnabled') ?? true;
      config['hapticsEnabled'] = _prefs.getBool('${_configPrefix}hapticsEnabled') ?? true;
      config['animationsEnabled'] = _prefs.getBool('${_configPrefix}animationsEnabled') ?? true;
      config['lastDifficulty'] = _prefs.getString('${_configPrefix}lastDifficulty') ?? GameDifficulty.medium.name;

      return config;
    } catch (e) {
      throw Exception('Failed to load game config: $e');
    }
  }

  @override
  Future<void> saveGameConfig(Map<String, dynamic> config) async {
    try {
      for (final entry in config.entries) {
        final key = '$_configPrefix${entry.key}';
        final value = entry.value;

        if (value is bool) {
          await _prefs.setBool(key, value);
        } else if (value is String) {
          await _prefs.setString(key, value);
        } else if (value is int) {
          await _prefs.setInt(key, value);
        }
      }
    } catch (e) {
      throw Exception('Failed to save game config: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      final keys = _prefs.getKeys().where(
        (key) =>
            key.startsWith(_highScorePrefix) || key.startsWith(_configPrefix),
      );

      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }
}
