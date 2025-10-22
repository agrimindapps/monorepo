// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Domain imports:
import '../entities/high_score_entity.dart';
import '../repositories/flappbird_repository.dart';

/// Use case to load high score from storage
class LoadHighScoreUseCase {
  final FlappbirdRepository _repository;

  LoadHighScoreUseCase(this._repository);

  Future<Either<Failure, HighScoreEntity>> call() async {
    try {
      return await _repository.loadHighScore();
    } catch (e) {
      return Left(UnexpectedFailure('Failed to load high score: $e'));
    }
  }
}
