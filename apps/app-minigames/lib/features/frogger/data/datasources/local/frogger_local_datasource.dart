import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/frogger_score_model.dart';
import '../../models/frogger_stats_model.dart';
import '../../models/frogger_settings_model.dart';

class FroggerLocalDatasource {
  final SharedPreferences _prefs;

  static const _scoresKey = 'frogger_scores';
  static const _statsKey = 'frogger_stats';
  static const _settingsKey = 'frogger_settings';

  FroggerLocalDatasource(this._prefs);

  // Scores
  Future<List<FroggerScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    final scores = jsonList
        .map((json) => FroggerScoreModel.fromJson(json as Map<String, dynamic>))
        .toList();

    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  Future<void> saveScore(FroggerScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, json.encode(jsonList));
  }

  Future<void> deleteScore(FroggerScoreModel score) async {
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
  Future<FroggerStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return const FroggerStatsModel();

    return FroggerStatsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveStats(FroggerStatsModel stats) async {
    await _prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<void> clearStats() async {
    await _prefs.remove(_statsKey);
  }

  // Settings
  Future<FroggerSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const FroggerSettingsModel();

    return FroggerSettingsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(FroggerSettingsModel settings) async {
    await _prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }
}
