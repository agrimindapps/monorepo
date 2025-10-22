import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/repositories/memory_repository.dart';
import '../datasources/memory_local_datasource.dart';
import '../models/high_score_model.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final MemoryLocalDataSource _localDataSource;

  MemoryRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, HighScoreEntity>> loadHighScore(
    GameDifficulty difficulty,
  ) async {
    try {
      final highScore = await _localDataSource.loadHighScore(difficulty);
      return Right(highScore.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to load high score: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore(
    HighScoreEntity highScore,
  ) async {
    try {
      final model = HighScoreModel.fromEntity(highScore);
      await _localDataSource.saveHighScore(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save high score: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> loadGameConfig() async {
    try {
      final config = await _localDataSource.loadGameConfig();
      return Right(config);
    } catch (e) {
      return Left(CacheFailure('Failed to load game config: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGameConfig(
    Map<String, dynamic> config,
  ) async {
    try {
      await _localDataSource.saveGameConfig(config);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save game config: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    try {
      await _localDataSource.clearAllData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear all data: $e'));
    }
  }
}
