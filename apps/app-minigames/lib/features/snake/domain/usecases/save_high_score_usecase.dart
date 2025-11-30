// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../repositories/snake_repository.dart';

/// Use case to save high score
class SaveHighScoreUseCase {
  final SnakeRepository repository;

  SaveHighScoreUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, void>> call({required int score}) async {
    // Validation: score must be non-negative
    if (score < 0) {
      return const Left(ValidationFailure('Score cannot be negative'));
    }

    return await repository.saveHighScore(score);
  }
}
