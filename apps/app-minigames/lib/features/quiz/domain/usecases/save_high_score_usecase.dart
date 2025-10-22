// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../repositories/quiz_repository.dart';

/// Use case to save high score
@injectable
class SaveHighScoreUseCase {
  final QuizRepository repository;

  SaveHighScoreUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, void>> call({required int score}) async {
    // Validation: score must be non-negative
    if (score < 0) {
      return Left(ValidationFailure('Score cannot be negative'));
    }

    return await repository.saveHighScore(score);
  }
}
