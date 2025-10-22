import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/enums.dart';
import '../entities/high_score_entity.dart';
import '../repositories/sudoku_repository.dart';

/// Use case for loading high score
class LoadHighScoreUseCase {
  final SudokuRepository _repository;

  LoadHighScoreUseCase(this._repository);

  /// Load high score for a difficulty
  /// Returns Either<Failure, HighScoreEntity>
  Future<Either<Failure, HighScoreEntity>> call(
    GameDifficulty difficulty,
  ) async {
    try {
      return await _repository.loadHighScore(difficulty);
    } catch (e) {
      return Left(UnexpectedFailure('Error loading high score: $e'));
    }
  }

  /// Load all high scores
  Future<Either<Failure, List<HighScoreEntity>>> loadAll() async {
    try {
      return await _repository.getAllHighScores();
    } catch (e) {
      return Left(UnexpectedFailure('Error loading all high scores: $e'));
    }
  }
}
