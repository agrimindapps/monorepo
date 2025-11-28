// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/high_score_entity.dart';
import '../entities/achievement.dart';
import '../entities/flappy_statistics.dart';

/// Repository interface for Flappy Bird game persistence
abstract class FlappbirdRepository {
  /// Load high score from local storage
  Future<Either<Failure, HighScoreEntity>> loadHighScore();

  /// Save high score to local storage
  Future<Either<Failure, void>> saveHighScore({required int score});

  /// Load achievements from local storage
  Future<Either<Failure, List<FlappyAchievement>>> loadAchievements();

  /// Save achievements to local storage
  Future<Either<Failure, void>> saveAchievements({
    required List<FlappyAchievement> achievements,
  });

  /// Load statistics from local storage
  Future<Either<Failure, FlappyStatistics>> loadStatistics();

  /// Save statistics to local storage
  Future<Either<Failure, void>> saveStatistics({
    required FlappyStatistics statistics,
  });

  /// Clear all data
  Future<Either<Failure, void>> clearAll();
}
