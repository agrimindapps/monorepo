import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/enums.dart';
import '../models/high_score_model.dart';

/// Local data source for 2048 game using SharedPreferences
class Game2048LocalDataSource {
  final SharedPreferences _prefs;

  static const String _highScorePrefix = 'game_2048_high_score_';
  static const String _settingsKey = 'game_2048_settings';

  Game2048LocalDataSource(this._prefs);

  /// Loads high score for specific board size
  Future<HighScoreModel?> loadHighScore(BoardSize boardSize) async {
    try {
      final key = '$_highScorePrefix${boardSize.name}';
      final jsonString = _prefs.getString(key);

      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScoreModel.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load high score: $e');
    }
  }

  /// Saves high score for specific board size
  Future<void> saveHighScore(HighScoreModel highScore) async {
    try {
      final key = '$_highScorePrefix${highScore.boardSize.name}';
      final jsonString = jsonEncode(highScore.toJson());
      await _prefs.setString(key, jsonString);
    } catch (e) {
      throw Exception('Failed to save high score: $e');
    }
  }

  /// Loads game settings
  Future<Map<String, dynamic>?> loadSettings() async {
    try {
      final jsonString = _prefs.getString(_settingsKey);

      if (jsonString == null) {
        return null;
      }

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  /// Saves game settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      await _prefs.setString(_settingsKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  /// Clears all saved data
  Future<void> clearAllData() async {
    try {
      final keys = _prefs.getKeys();
      final game2048Keys = keys.where(
        (key) => key.startsWith('game_2048_'),
      );

      for (final key in game2048Keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }
}
