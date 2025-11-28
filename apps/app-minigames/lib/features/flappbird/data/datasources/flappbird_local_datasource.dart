// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Data imports:
import '../models/high_score_model.dart';
import '../models/achievement_model.dart';
import '../models/flappy_statistics_model.dart';

/// Local data source for Flappy Bird game (SharedPreferences)
class FlappbirdLocalDataSource {
  final SharedPreferences _prefs;

  /// SharedPreferences key for high score
  static const String _highScoreKey = 'flappbird_high_score';
  static const String _achievementsKey = 'flappbird_achievements';
  static const String _statisticsKey = 'flappbird_statistics';

  FlappbirdLocalDataSource(this._prefs);

  /// Load high score from SharedPreferences
  Future<HighScoreModel> loadHighScore() async {
    try {
      final jsonString = _prefs.getString(_highScoreKey);

      if (jsonString == null) {
        return HighScoreModel.empty();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScoreModel.fromJson(json);
    } catch (e) {
      // If error, return empty score
      return HighScoreModel.empty();
    }
  }

  /// Save high score to SharedPreferences
  Future<void> saveHighScore(HighScoreModel highScore) async {
    final jsonString = jsonEncode(highScore.toJson());
    await _prefs.setString(_highScoreKey, jsonString);
  }

  /// Load achievements from SharedPreferences
  Future<FlappyAchievementsDataModel> loadAchievements() async {
    try {
      final jsonString = _prefs.getString(_achievementsKey);

      if (jsonString == null) {
        return FlappyAchievementsDataModel.empty();
      }

      return FlappyAchievementsDataModel.fromJsonString(jsonString);
    } catch (e) {
      return FlappyAchievementsDataModel.empty();
    }
  }

  /// Save achievements to SharedPreferences
  Future<void> saveAchievements(FlappyAchievementsDataModel achievements) async {
    final jsonString = achievements.toJsonString();
    await _prefs.setString(_achievementsKey, jsonString);
  }

  /// Load statistics from SharedPreferences
  Future<FlappyStatisticsModel> loadStatistics() async {
    try {
      final jsonString = _prefs.getString(_statisticsKey);

      if (jsonString == null) {
        return FlappyStatisticsModel.empty();
      }

      return FlappyStatisticsModel.fromJsonString(jsonString);
    } catch (e) {
      return FlappyStatisticsModel.empty();
    }
  }

  /// Save statistics to SharedPreferences
  Future<void> saveStatistics(FlappyStatisticsModel statistics) async {
    final jsonString = statistics.toJsonString();
    await _prefs.setString(_statisticsKey, jsonString);
  }

  /// Clear all Flappy Bird data
  Future<void> clearAll() async {
    await _prefs.remove(_highScoreKey);
    await _prefs.remove(_achievementsKey);
    await _prefs.remove(_statisticsKey);
  }
}
