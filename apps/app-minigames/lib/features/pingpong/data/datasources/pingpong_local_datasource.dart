import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/enums.dart';
import '../models/high_score_model.dart';

abstract class PingpongLocalDataSource {
  Future<HighScoreModel?> getHighScore(GameDifficulty difficulty);
  Future<void> saveHighScore(HighScoreModel highScore);
  Future<void> clearHighScores();
}

class PingpongLocalDataSourceImpl implements PingpongLocalDataSource {
  final SharedPreferences sharedPreferences;

  PingpongLocalDataSourceImpl(this.sharedPreferences);

  static const String _highScorePrefix = 'pingpong_high_score_';

  String _getKey(GameDifficulty difficulty) =>
      '$_highScorePrefix${difficulty.name}';

  @override
  Future<HighScoreModel?> getHighScore(GameDifficulty difficulty) async {
    try {
      final key = _getKey(difficulty);
      final jsonString = sharedPreferences.getString(key);

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScoreModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveHighScore(HighScoreModel highScore) async {
    final key = _getKey(highScore.difficulty);
    final jsonString = jsonEncode(highScore.toJson());
    await sharedPreferences.setString(key, jsonString);
  }

  @override
  Future<void> clearHighScores() async {
    for (final difficulty in GameDifficulty.values) {
      final key = _getKey(difficulty);
      await sharedPreferences.remove(key);
    }
  }
}
