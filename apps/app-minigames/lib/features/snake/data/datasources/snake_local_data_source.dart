// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Core imports:
import 'package:app_minigames/core/error/exceptions.dart';

// Data imports:
import '../models/high_score_model.dart';

/// Interface for snake local data source
abstract class SnakeLocalDataSource {
  /// Load high score
  Future<HighScoreModel> loadHighScore();

  /// Save high score
  Future<void> saveHighScore(int score);
}

/// Implementation of snake local data source
class SnakeLocalDataSourceImpl implements SnakeLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _highScoreKey = 'snake_high_score';

  SnakeLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<HighScoreModel> loadHighScore() async {
    try {
      final score = sharedPreferences.getInt(_highScoreKey) ?? 0;
      return HighScoreModel(score: score);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveHighScore(int score) async {
    try {
      await sharedPreferences.setInt(_highScoreKey, score);
    } catch (e) {
      throw CacheException();
    }
  }
}
