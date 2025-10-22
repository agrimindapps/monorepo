// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Data imports:
import '../models/high_score_model.dart';

/// Local data source for Flappy Bird game (SharedPreferences)
class FlappbirdLocalDataSource {
  final SharedPreferences _prefs;

  /// SharedPreferences key for high score
  static const String _highScoreKey = 'flappbird_high_score';

  FlappbirdLocalDataSource(this._prefs);

  /// Load high score from SharedPreferences
  Future<HighScoreModel> loadHighScore() async {
    try {
      final jsonString = _prefs.getString(_highScoreKey);

      if (jsonString == null) {
        return HighScoreModel.empty();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScoreModel.fromJson(json);
    } catch (e) {
      // If error, return empty score
      return HighScoreModel.empty();
    }
  }

  /// Save high score to SharedPreferences
  Future<void> saveHighScore(HighScoreModel highScore) async {
    final jsonString = jsonEncode(highScore.toJson());
    await _prefs.setString(_highScoreKey, jsonString);
  }
}
