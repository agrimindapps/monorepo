import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/high_score_model.dart';

/// Contract for local data operations
abstract class TowerLocalDataSource {
  /// Gets high score from local storage
  Future<HighScoreModel> getHighScore();

  /// Saves high score to local storage
  Future<void> saveHighScore(int score);
}

/// Implementation of TowerLocalDataSource using SharedPreferences
@LazySingleton(as: TowerLocalDataSource)
class TowerLocalDataSourceImpl implements TowerLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _highScoreKey = 'tower_high_score';

  TowerLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<HighScoreModel> getHighScore() async {
    try {
      final score = sharedPreferences.getInt(_highScoreKey) ?? 0;
      return HighScoreModel(score: score);
    } catch (e) {
      throw CacheException('Failed to load high score: ${e.toString()}');
    }
  }

  @override
  Future<void> saveHighScore(int score) async {
    try {
      final success = await sharedPreferences.setInt(_highScoreKey, score);
      if (!success) {
        throw CacheException('Failed to save high score');
      }
    } catch (e) {
      throw CacheException('Failed to save high score: ${e.toString()}');
    }
  }
}
