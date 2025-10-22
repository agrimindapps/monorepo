import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/high_score_entity.dart';

/// Repository interface for 2048 game data operations
abstract class Game2048Repository {
  /// Loads high score for specific board size
  Future<Either<Failure, HighScoreEntity>> loadHighScore(BoardSize boardSize);

  /// Saves high score for specific board size
  Future<Either<Failure, Unit>> saveHighScore(HighScoreEntity highScore);

  /// Loads game settings (color scheme, sound, etc)
  Future<Either<Failure, Map<String, dynamic>>> loadSettings();

  /// Saves game settings
  Future<Either<Failure, Unit>> saveSettings(Map<String, dynamic> settings);

  /// Clears all saved data
  Future<Either<Failure, Unit>> clearAllData();
}
