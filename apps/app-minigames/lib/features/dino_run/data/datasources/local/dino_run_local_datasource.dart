import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/dino_run_score_model.dart';
import '../../models/dino_run_stats_model.dart';
import '../../models/dino_run_settings_model.dart';

class DinoRunLocalDatasource {
  final SharedPreferences _prefs;

  static const _scoresKey = 'dino_run_scores';
  static const _statsKey = 'dino_run_stats';
  static const _settingsKey = 'dino_run_settings';

  DinoRunLocalDatasource(this._prefs);

  // Scores
  Future<List<DinoRunScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    final scores = jsonList
        .map((json) => DinoRunScoreModel.fromJson(json as Map<String, dynamic>))
        .toList();

    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  Future<void> saveScore(DinoRunScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, json.encode(jsonList));
  }

  Future<void> deleteScore(DinoRunScoreModel score) async {
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
  Future<DinoRunStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return const DinoRunStatsModel();

    return DinoRunStatsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveStats(DinoRunStatsModel stats) async {
    await _prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<void> clearStats() async {
    await _prefs.remove(_statsKey);
  }

  // Settings
  Future<DinoRunSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const DinoRunSettingsModel();

    return DinoRunSettingsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(DinoRunSettingsModel settings) async {
    await _prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }
}
