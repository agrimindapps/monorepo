import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/batalha_naval_score_model.dart';
import '../../models/batalha_naval_stats_model.dart';
import '../../models/batalha_naval_settings_model.dart';

class BatalhaNavalLocalDatasource {
  final SharedPreferences _prefs;
  static const _scoresKey = 'batalha_naval_scores';
  static const _statsKey = 'batalha_naval_stats';
  static const _settingsKey = 'batalha_naval_settings';

  BatalhaNavalLocalDatasource(this._prefs);

  Future<List<BatalhaNavalScoreModel>> getHighScores() async {
    final jsonList = _prefs.getStringList(_scoresKey) ?? [];
    return jsonList
        .map((json) => BatalhaNavalScoreModel.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveScore(BatalhaNavalScoreModel score) async {
    final scores = await getHighScores();
    scores.add(score);
    // Keep only top 50
    final reducedScores = scores.take(50).toList();
    await _prefs.setStringList(
      _scoresKey,
      reducedScores.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<void> deleteScore(BatalhaNavalScoreModel score) async {
    final scores = await getHighScores();
    scores.removeWhere(
      (s) => s.timestamp == score.timestamp && s.shotsFired == score.shotsFired,
    );
    await _prefs.setStringList(
      _scoresKey,
      scores.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<BatalhaNavalStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return BatalhaNavalStatsModel();
    return BatalhaNavalStatsModel.fromJson(jsonDecode(jsonString));
  }

  Future<void> updateStats(BatalhaNavalStatsModel stats) async {
    await _prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
  }

  Future<BatalhaNavalSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return BatalhaNavalSettingsModel();
    return BatalhaNavalSettingsModel.fromJson(jsonDecode(jsonString));
  }

  Future<void> saveSettings(BatalhaNavalSettingsModel settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
