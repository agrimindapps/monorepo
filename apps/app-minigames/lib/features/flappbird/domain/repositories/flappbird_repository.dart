// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/high_score_entity.dart';

/// Repository interface for Flappy Bird game persistence
abstract class FlappbirdRepository {
  /// Load high score from local storage
  Future<Either<Failure, HighScoreEntity>> loadHighScore();

  /// Save high score to local storage
  Future<Either<Failure, void>> saveHighScore({required int score});
}
