import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/space_invaders_score_model.dart';
import '../../models/space_invaders_stats_model.dart';
import '../../models/space_invaders_settings_model.dart';

class SpaceInvadersLocalDatasource {
  final SharedPreferences _prefs;

  static const String _scoresKey = 'space_invaders_scores';
  static const String _statsKey = 'space_invaders_stats';
  static const String _settingsKey = 'space_invaders_settings';

  SpaceInvadersLocalDatasource(this._prefs);

  Future<void> saveScore(SpaceInvadersScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));
    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, jsonEncode(jsonList));
  }

  Future<List<SpaceInvadersScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => SpaceInvadersScoreModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<SpaceInvadersScoreModel>> getTopScores({int limit = 10}) async {
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

  Future<SpaceInvadersStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return const SpaceInvadersStatsModel();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SpaceInvadersStatsModel.fromJson(json);
  }

  Future<void> updateStats(SpaceInvadersStatsModel stats) async {
    final jsonString = jsonEncode(stats.toJson());
    await _prefs.setString(_statsKey, jsonString);
  }

  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
  }

  Future<SpaceInvadersSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const SpaceInvadersSettingsModel();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SpaceInvadersSettingsModel.fromJson(json);
  }

  Future<void> saveSettings(SpaceInvadersSettingsModel settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }

  Future<void> resetSettings() async {
    await _prefs.remove(_settingsKey);
  }
}
