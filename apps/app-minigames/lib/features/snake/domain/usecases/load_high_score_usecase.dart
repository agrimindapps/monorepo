// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/high_score.dart';
import '../repositories/snake_repository.dart';

/// Use case to load high score
class LoadHighScoreUseCase {
  final SnakeRepository repository;

  LoadHighScoreUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, HighScore>> call() async {
    return await repository.loadHighScore();
  }
}
