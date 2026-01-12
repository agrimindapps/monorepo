import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/damas_score_model.dart';
import '../../models/damas_stats_model.dart';
import '../../models/damas_settings_model.dart';

class DamasLocalDatasource {
  final SharedPreferences _prefs;

  static const String _scoresKey = 'damas_scores';
  static const String _statsKey = 'damas_stats';
  static const String _settingsKey = 'damas_settings';

  DamasLocalDatasource(this._prefs);

  // Score operations
  Future<void> saveScore(DamasScoreModel score) async {
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, jsonEncode(jsonList));
  }

  Future<List<DamasScoreModel>> getScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => DamasScoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteScore(String id) async {
    final scores = await getScores();
    scores.removeWhere((score) => score.id == id);

    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, jsonEncode(jsonList));
  }

  // Stats operations
  Future<DamasStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) {
      return const DamasStatsModel();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DamasStatsModel.fromJson(json);
    } catch (_) {
      return const DamasStatsModel();
    }
  }

  Future<void> updateStats(DamasStatsModel stats) async {
    final jsonString = jsonEncode(stats.toJson());
    await _prefs.setString(_statsKey, jsonString);
  }

  // Settings operations
  Future<DamasSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) {
      return const DamasSettingsModel();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DamasSettingsModel.fromJson(json);
    } catch (_) {
      return const DamasSettingsModel();
    }
  }

  Future<void> saveSettings(DamasSettingsModel settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }
}
