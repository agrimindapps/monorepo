import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/high_score_entity.dart';
import '../entities/word_entity.dart';

/// Failure types for repository operations
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Repository interface for Soletrando game data
abstract class SoletrandoRepository {
  /// Get random word for specified difficulty and category
  Future<Either<Failure, WordEntity>> getRandomWord({
    required GameDifficulty difficulty,
    required WordCategory category,
  });

  /// Load high scores from storage
  Future<Either<Failure, HighScoresCollection>> loadHighScores();

  /// Save high score for specific difficulty
  Future<Either<Failure, void>> saveHighScore(HighScoreEntity highScore);

  /// Load game settings (difficulty, sound, etc)
  Future<Either<Failure, Map<String, dynamic>>> loadSettings();

  /// Save game settings
  Future<Either<Failure, void>> saveSettings(Map<String, dynamic> settings);
}
