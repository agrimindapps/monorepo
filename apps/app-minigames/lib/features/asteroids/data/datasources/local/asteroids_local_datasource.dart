import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/asteroids_score_model.dart';
import '../../models/asteroids_stats_model.dart';
import '../../models/asteroids_settings_model.dart';

class AsteroidsLocalDatasource {
  final SharedPreferences _prefs;

  static const _scoresKey = 'asteroids_scores';
  static const _statsKey = 'asteroids_stats';
  static const _settingsKey = 'asteroids_settings';

  AsteroidsLocalDatasource(this._prefs);

  // Scores
  Future<List<AsteroidsScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    final scores = jsonList
        .map((json) => AsteroidsScoreModel.fromJson(json as Map<String, dynamic>))
        .toList();

    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  Future<void> saveScore(AsteroidsScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, json.encode(jsonList));
  }

  Future<void> deleteScore(AsteroidsScoreModel score) async {
    final scores = await getScores();
    scores.removeWhere((s) => 
      s.score == score.score && 
      s.timestamp == score.timestamp
    );

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, json.encode(jsonList));
  }

  Future<void> clearAllScores() async {
    await _prefs.remove(_scoresKey);
  }

  // Stats
  Future<AsteroidsStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return const AsteroidsStatsModel();

    return AsteroidsStatsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveStats(AsteroidsStatsModel stats) async {
    await _prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<void> clearStats() async {
    await _prefs.remove(_statsKey);
  }

  // Settings
  Future<AsteroidsSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const AsteroidsSettingsModel();

    return AsteroidsSettingsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(AsteroidsSettingsModel settings) async {
    await _prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }
}
