import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/tetris_score_model.dart';
import '../../models/tetris_stats_model.dart';
import '../../models/tetris_settings_model.dart';

/// Datasource local para persistência do Tetris usando SharedPreferences
class TetrisLocalDatasource {
  final SharedPreferences _prefs;

  static const _scoresKey = 'tetris_scores';
  static const _statsKey = 'tetris_stats';
  static const _settingsKey = 'tetris_settings';

  TetrisLocalDatasource(this._prefs);

  // ========== SCORES ==========

  /// Salva um score
  Future<void> saveScore(TetrisScoreModel score) async {
    final scores = await getAllScores();
    scores.add(score);
    
    // Ordena por score (maior primeiro)
    scores.sort((a, b) => b.score.compareTo(a.score));
    
    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, json.encode(jsonList));
  }

  /// Obtém todos os scores
  Future<List<TetrisScoreModel>> getAllScores() async {
    final jsonString = _prefs.getString(_scoresKey);
    if (jsonString == null) return [];

    try {
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => TetrisScoreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtém top N scores
  Future<List<TetrisScoreModel>> getTopScores(int limit) async {
    final allScores = await getAllScores();
    return allScores.take(limit).toList();
  }

  /// Obtém scores de hoje
  Future<List<TetrisScoreModel>> getTodayScores() async {
    final allScores = await getAllScores();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return allScores.where((score) {
      final scoreDate = DateTime(
        score.completedAt.year,
        score.completedAt.month,
        score.completedAt.day,
      );
      return scoreDate == today;
    }).toList();
  }

  /// Obtém scores desta semana
  Future<List<TetrisScoreModel>> getWeekScores() async {
    final allScores = await getAllScores();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return allScores.where((score) {
      return score.completedAt.isAfter(weekAgo);
    }).toList();
  }

  /// Deleta um score específico
  Future<void> deleteScore(String id) async {
    final scores = await getAllScores();
    scores.removeWhere((score) => score.id == id);
    
    final jsonList = scores.map((s) => s.toJson()).toList();
    await _prefs.setString(_scoresKey, json.encode(jsonList));
  }

  /// Deleta todos os scores
  Future<void> deleteAllScores() async {
    await _prefs.remove(_scoresKey);
  }

  /// Obtém o melhor score
  Future<TetrisScoreModel?> getBestScore() async {
    final scores = await getAllScores();
    if (scores.isEmpty) return null;
    return scores.first; // Já está ordenado por score
  }

  // ========== STATS ==========

  /// Obtém as estatísticas
  Future<TetrisStatsModel> getStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) return const TetrisStatsModel();

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return TetrisStatsModel.fromJson(jsonMap);
    } catch (e) {
      return const TetrisStatsModel();
    }
  }

  /// Salva as estatísticas
  Future<void> saveStats(TetrisStatsModel stats) async {
    final jsonString = json.encode(stats.toJson());
    await _prefs.setString(_statsKey, jsonString);
  }

  /// Reseta as estatísticas
  Future<void> resetStats() async {
    await _prefs.remove(_statsKey);
  }

  // ========== SETTINGS ==========

  /// Obtém as configurações
  Future<TetrisSettingsModel> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) return const TetrisSettingsModel();

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return TetrisSettingsModel.fromJson(jsonMap);
    } catch (e) {
      return const TetrisSettingsModel();
    }
  }

  /// Salva as configurações
  Future<void> saveSettings(TetrisSettingsModel settings) async {
    final jsonString = json.encode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }

  /// Reseta as configurações
  Future<void> resetSettings() async {
    await _prefs.remove(_settingsKey);
  }
}
