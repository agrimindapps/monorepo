import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/arkanoid_score_model.dart';
import '../../models/arkanoid_stats_model.dart';
import '../../models/arkanoid_settings_model.dart';

class ArkanoidLocalDatasource {
  final SharedPreferences _prefs;

  static const String _scoresKey = 'arkanoid_scores';
  static const String _statsKey = 'arkanoid_stats';
  static const String _settingsKey = 'arkanoid_settings';

  ArkanoidLocalDatasource(this._prefs);

  Future<void> saveScore(ArkanoidScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));
    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, jsonEncode(jsonList));
  }

  Future<List<ArkanoidScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => ArkanoidScoreModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<ArkanoidScoreModel>> getTopScores({int limit = 10}) async {
    final scores = await getScores();
    return scores.take(limit).toList();
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

  Future<ArkanoidStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return const ArkanoidStatsModel();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ArkanoidStatsModel.fromJson(json);
  }

  Future<void> updateStats(ArkanoidStatsModel stats) async {
    final jsonString = jsonEncode(stats.toJson());
    await _prefs.setString(_statsKey, jsonString);
  }

  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
  }

  Future<ArkanoidSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const ArkanoidSettingsModel();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ArkanoidSettingsModel.fromJson(json);
  }

  Future<void> saveSettings(ArkanoidSettingsModel settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }

  Future<void> resetSettings() async {
    await _prefs.remove(_settingsKey);
  }
}
