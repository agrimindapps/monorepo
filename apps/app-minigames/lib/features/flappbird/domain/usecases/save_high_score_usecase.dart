// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Domain imports:
import '../repositories/flappbird_repository.dart';

/// Use case to save high score to storage
class SaveHighScoreUseCase {
  final FlappbirdRepository _repository;

  SaveHighScoreUseCase(this._repository);

  Future<Either<Failure, void>> call({required int score}) async {
    try {
      // Validate score
      if (score < 0) {
        return Left(ValidationFailure('Score cannot be negative'));
      }

      return await _repository.saveHighScore(score: score);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to save high score: $e'));
    }
  }
}
