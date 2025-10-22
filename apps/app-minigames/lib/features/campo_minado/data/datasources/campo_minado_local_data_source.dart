import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/game_stats_model.dart';
import '../../domain/entities/enums.dart';

/// Local data source for Campo Minado game using SharedPreferences
class CampoMinadoLocalDataSource {
  final SharedPreferences _prefs;

  const CampoMinadoLocalDataSource(this._prefs);

  // Storage keys
  static const String _keyPrefix = 'campo_minado_';
  static const String _statsBeginnerKey = '${_keyPrefix}stats_beginner';
  static const String _statsIntermediateKey = '${_keyPrefix}stats_intermediate';
  static const String _statsExpertKey = '${_keyPrefix}stats_expert';
  static const String _globalStatsKey = '${_keyPrefix}stats_global';

  /// Gets storage key for difficulty
  String _getKeyForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return _statsBeginnerKey;
      case Difficulty.intermediate:
        return _statsIntermediateKey;
      case Difficulty.expert:
        return _statsExpertKey;
      case Difficulty.custom:
        return '${_keyPrefix}stats_custom';
    }
  }

  /// Loads statistics for a difficulty
  Future<GameStatsModel> loadStats(Difficulty difficulty) async {
    try {
      final key = _getKeyForDifficulty(difficulty);
      final jsonString = _prefs.getString(key);

      if (jsonString == null) {
        return GameStatsModel.empty(difficulty: difficulty);
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameStatsModel.fromJson(json);
    } catch (e) {
      // Return empty stats on error
      return GameStatsModel.empty(difficulty: difficulty);
    }
  }

  /// Saves statistics for a difficulty
  Future<void> saveStats(GameStatsModel stats) async {
    final key = _getKeyForDifficulty(stats.difficulty);
    final jsonString = jsonEncode(stats.toJson());
    await _prefs.setString(key, jsonString);
  }

  /// Resets statistics for a difficulty
  Future<void> resetStats(Difficulty difficulty) async {
    final key = _getKeyForDifficulty(difficulty);
    await _prefs.remove(key);
  }

  /// Loads global statistics (combined from all difficulties)
  Future<GameStatsModel> loadGlobalStats() async {
    try {
      final beginnerStats = await loadStats(Difficulty.beginner);
      final intermediateStats = await loadStats(Difficulty.intermediate);
      final expertStats = await loadStats(Difficulty.expert);

      final totalGames = beginnerStats.totalGames +
          intermediateStats.totalGames +
          expertStats.totalGames;

      final totalWins = beginnerStats.totalWins +
          intermediateStats.totalWins +
          expertStats.totalWins;

      final bestStreak = [
        beginnerStats.bestStreak,
        intermediateStats.bestStreak,
        expertStats.bestStreak,
      ].reduce((a, b) => a > b ? a : b);

      // Find best time across all difficulties (non-zero)
      final allBestTimes = [
        beginnerStats.bestTime,
        intermediateStats.bestTime,
        expertStats.bestTime,
      ].where((t) => t > 0).toList();

      final bestTime = allBestTimes.isEmpty
          ? 0
          : allBestTimes.reduce((a, b) => a < b ? a : b);

      return GameStatsModel(
        difficulty: Difficulty.beginner, // Not used for global
        bestTime: bestTime,
        totalGames: totalGames,
        totalWins: totalWins,
        currentStreak: 0, // Not meaningful for global
        bestStreak: bestStreak,
      );
    } catch (e) {
      return GameStatsModel.empty();
    }
  }

  /// Clears all game data
  Future<void> clearAllData() async {
    await _prefs.remove(_statsBeginnerKey);
    await _prefs.remove(_statsIntermediateKey);
    await _prefs.remove(_statsExpertKey);
    await _prefs.remove(_globalStatsKey);
  }
}
