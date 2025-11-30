import 'package:core/core.dart';
import '../entities/high_score_entity.dart';
import '../repositories/sudoku_repository.dart';

/// Use case for saving high score
class SaveHighScoreUseCase {
  final SudokuRepository _repository;

  SaveHighScoreUseCase(this._repository);

  /// Save high score
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> call(HighScoreEntity highScore) async {
    try {
      // Validate high score
      if (highScore.bestTime < 0) {
        return const Left(
          ValidationFailure('Best time cannot be negative'),
        );
      }

      if (highScore.fewestMistakes < 0) {
        return const Left(
          ValidationFailure('Mistakes cannot be negative'),
        );
      }

      if (highScore.gamesCompleted < 0) {
        return const Left(
          ValidationFailure('Games completed cannot be negative'),
        );
      }

      return await _repository.saveHighScore(highScore);
    } catch (e) {
      return Left(UnexpectedFailure('Error saving high score: $e'));
    }
  }

  /// Clear all high scores
  Future<Either<Failure, void>> clearAll() async {
    try {
      return await _repository.clearAllHighScores();
    } catch (e) {
      return Left(UnexpectedFailure('Error clearing high scores: $e'));
    }
  }
}
