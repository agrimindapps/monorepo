import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/galaga_score_model.dart';
import '../../models/galaga_stats_model.dart';
import '../../models/galaga_settings_model.dart';

class GalagaLocalDatasource {
  final SharedPreferences _prefs;

  static const _scoresKey = 'galaga_scores';
  static const _statsKey = 'galaga_stats';
  static const _settingsKey = 'galaga_settings';

  GalagaLocalDatasource(this._prefs);

  // Scores
  Future<List<GalagaScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    final scores = jsonList
        .map((json) => GalagaScoreModel.fromJson(json as Map<String, dynamic>))
        .toList();

    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  Future<void> saveScore(GalagaScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, json.encode(jsonList));
  }

  Future<void> deleteScore(GalagaScoreModel score) async {
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
  Future<GalagaStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return const GalagaStatsModel();

    return GalagaStatsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveStats(GalagaStatsModel stats) async {
    await _prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<void> clearStats() async {
    await _prefs.remove(_statsKey);
  }

  // Settings
  Future<GalagaSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const GalagaSettingsModel();

    return GalagaSettingsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(GalagaSettingsModel settings) async {
    await _prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }
}
