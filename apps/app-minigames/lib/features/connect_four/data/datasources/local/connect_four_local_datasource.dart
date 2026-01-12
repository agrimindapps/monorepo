import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/connect_four_score_model.dart';
import '../../models/connect_four_stats_model.dart';
import '../../models/connect_four_settings_model.dart';

class ConnectFourLocalDatasource {
  final SharedPreferences _prefs;

  static const _scoresKey = 'connect_four_scores';
  static const _statsKey = 'connect_four_stats';
  static const _settingsKey = 'connect_four_settings';

  ConnectFourLocalDatasource(this._prefs);

  // Scores
  Future<List<ConnectFourScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    final scores = jsonList
        .map((json) => ConnectFourScoreModel.fromJson(json as Map<String, dynamic>))
        .toList();

    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  Future<void> saveScore(ConnectFourScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, json.encode(jsonList));
  }

  Future<void> deleteScore(ConnectFourScoreModel score) async {
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
  Future<ConnectFourStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return const ConnectFourStatsModel();

    return ConnectFourStatsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveStats(ConnectFourStatsModel stats) async {
    await _prefs.setString(_statsKey, json.encode(stats.toJson()));
  }

  Future<void> clearStats() async {
    await _prefs.remove(_statsKey);
  }

  // Settings
  Future<ConnectFourSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const ConnectFourSettingsModel();

    return ConnectFourSettingsModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(ConnectFourSettingsModel settings) async {
    await _prefs.setString(_settingsKey, json.encode(settings.toJson()));
  }
}
