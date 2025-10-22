import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/enums.dart';
import '../models/high_score_model.dart';

class SudokuLocalDataSource {
  final SharedPreferences _prefs;

  static const String _highScorePrefix = 'sudoku_high_score_';

  SudokuLocalDataSource(this._prefs);

  /// Get key for difficulty
  String _getKey(GameDifficulty difficulty) {
    return '$_highScorePrefix${difficulty.name}';
  }

  /// Load high score
  Future<HighScoreModel?> loadHighScore(GameDifficulty difficulty) async {
    try {
      final key = _getKey(difficulty);
      final jsonString = _prefs.getString(key);

      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScoreModel.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load high score: $e');
    }
  }

  /// Save high score
  Future<void> saveHighScore(HighScoreModel highScore) async {
    try {
      final key = _getKey(highScore.difficulty);
      final jsonString = jsonEncode(highScore.toJson());
      await _prefs.setString(key, jsonString);
    } catch (e) {
      throw Exception('Failed to save high score: $e');
    }
  }

  /// Get all high scores
  Future<List<HighScoreModel>> getAllHighScores() async {
    try {
      final highScores = <HighScoreModel>[];

      for (final difficulty in GameDifficulty.values) {
        final highScore = await loadHighScore(difficulty);
        if (highScore != null) {
          highScores.add(highScore);
        }
      }

      return highScores;
    } catch (e) {
      throw Exception('Failed to load all high scores: $e');
    }
  }

  /// Clear all high scores
  Future<void> clearAllHighScores() async {
    try {
      for (final difficulty in GameDifficulty.values) {
        final key = _getKey(difficulty);
        await _prefs.remove(key);
      }
    } catch (e) {
      throw Exception('Failed to clear high scores: $e');
    }
  }

  /// Check if high score exists
  bool hasHighScore(GameDifficulty difficulty) {
    final key = _getKey(difficulty);
    return _prefs.containsKey(key);
  }
}
