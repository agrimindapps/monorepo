// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Domain imports:
import '../../domain/entities/high_score_entity.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/flappy_statistics.dart';
import '../../domain/repositories/flappbird_repository.dart';

// Data imports:
import '../datasources/flappbird_local_datasource.dart';
import '../models/high_score_model.dart';
import '../models/achievement_model.dart';
import '../models/flappy_statistics_model.dart';

/// Implementation of FlappbirdRepository using local data source
class FlappbirdRepositoryImpl implements FlappbirdRepository {
  final FlappbirdLocalDataSource _localDataSource;

  FlappbirdRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, HighScoreEntity>> loadHighScore() async {
    try {
      final highScore = await _localDataSource.loadHighScore();
      return Right(highScore);
    } catch (e) {
      return Left(CacheFailure('Failed to load high score: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore({required int score}) async {
    try {
      final highScore = HighScoreModel(
        score: score,
        achievedAt: DateTime.now(),
      );

      await _localDataSource.saveHighScore(highScore);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save high score: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FlappyAchievement>>> loadAchievements() async {
    try {
      final data = await _localDataSource.loadAchievements();
      return Right(data.toEntities());
    } catch (e) {
      return Left(CacheFailure('Failed to load achievements: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAchievements({
    required List<FlappyAchievement> achievements,
  }) async {
    try {
      final data = FlappyAchievementsDataModel.fromEntities(achievements);
      await _localDataSource.saveAchievements(data);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save achievements: $e'));
    }
  }

  @override
  Future<Either<Failure, FlappyStatistics>> loadStatistics() async {
    try {
      final data = await _localDataSource.loadStatistics();
      return Right(data.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to load statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveStatistics({
    required FlappyStatistics statistics,
  }) async {
    try {
      final data = FlappyStatisticsModel.fromEntity(statistics);
      await _localDataSource.saveStatistics(data);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      await _localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear data: $e'));
    }
  }
}
