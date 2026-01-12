import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/reversi_score_model.dart';
import '../../models/reversi_stats_model.dart';
import '../../models/reversi_settings_model.dart';

class ReversiLocalDatasource {
  final SharedPreferences _prefs;

  static const String _scoresKey = 'reversi_scores';
  static const String _statsKey = 'reversi_stats';
  static const String _settingsKey = 'reversi_settings';

  ReversiLocalDatasource(this._prefs);

  // Score operations
  Future<void> saveScore(ReversiScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.scoreDifference.compareTo(a.scoreDifference));

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, jsonEncode(jsonList));
  }

  Future<List<ReversiScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => ReversiScoreModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReversiScoreModel>> getTopScores({int limit = 10}) async {
    final scores = await getScores();
    return scores.take(limit).toList();
  }

  Future<List<ReversiScoreModel>> getTodayScores() async {
    final scores = await getScores();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return scores.where((score) {
      final scoreDate = DateTime(
        score.completedAt.year,
        score.completedAt.month,
        score.completedAt.day,
      );
      return scoreDate == today;
    }).toList();
  }

  Future<void> deleteScore(String id) async {
    final scores = await getScores();
    scores.removeWhere((score) => score.id == id);

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, jsonEncode(jsonList));
  }

  Future<void> deleteAllScores() async {
    await _prefs.remove(_scoresKey);
  }

  // Stats operations
  Future<ReversiStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) {
      return const ReversiStatsModel();
    }

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ReversiStatsModel.fromJson(json);
  }

  Future<void> updateStats(ReversiStatsModel stats) async {
    final jsonString = jsonEncode(stats.toJson());
    await _prefs.setString(_statsKey, jsonString);
  }

  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
  }

  // Settings operations
  Future<ReversiSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) {
      return const ReversiSettingsModel();
    }

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ReversiSettingsModel.fromJson(json);
  }

  Future<void> saveSettings(ReversiSettingsModel settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }

  Future<void> resetSettings() async {
    await _prefs.remove(_settingsKey);
  }
}
