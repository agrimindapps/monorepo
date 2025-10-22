import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/enums.dart';
import '../entities/high_score.dart';

/// Repository interface for word search game data operations
abstract class CacaPalavraRepository {
  /// Loads high score from local storage
  Future<Either<Failure, HighScore>> loadHighScore();

  /// Saves high score to local storage
  Future<Either<Failure, void>> saveHighScore(HighScore highScore);

  /// Gets list of available words for the game
  Future<Either<Failure, List<String>>> getAvailableWords();

  /// Saves game difficulty preference
  Future<Either<Failure, void>> saveDifficulty(GameDifficulty difficulty);

  /// Loads game difficulty preference
  Future<Either<Failure, GameDifficulty>> loadDifficulty();
}
