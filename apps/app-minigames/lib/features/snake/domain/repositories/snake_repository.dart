// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/high_score.dart';

/// Repository interface for snake operations
abstract class SnakeRepository {
  /// Load high score
  Future<Either<Failure, HighScore>> loadHighScore();

  /// Save high score
  Future<Either<Failure, void>> saveHighScore(int score);
}
