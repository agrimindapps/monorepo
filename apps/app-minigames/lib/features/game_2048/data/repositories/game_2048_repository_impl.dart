import 'package:core/core.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/repositories/game_2048_repository.dart';
import '../datasources/game_2048_local_datasource.dart';
import '../models/high_score_model.dart';

/// Implementation of Game2048Repository
class Game2048RepositoryImpl implements Game2048Repository {
  final Game2048LocalDataSource _localDataSource;

  Game2048RepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, HighScoreEntity>> loadHighScore(
    BoardSize boardSize,
  ) async {
    try {
      final highScore = await _localDataSource.loadHighScore(boardSize);

      if (highScore == null) {
        // Return empty high score if none exists
        return Right(HighScoreModel.empty(boardSize));
      }

      return Right(highScore);
    } catch (e) {
      return Left(CacheFailure('Failed to load high score: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveHighScore(
    HighScoreEntity highScore,
  ) async {
    try {
      final model = HighScoreModel.fromEntity(highScore);
      await _localDataSource.saveHighScore(model);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save high score: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> loadSettings() async {
    try {
      final settings = await _localDataSource.loadSettings();

      if (settings == null) {
        // Return default settings
        return Right({
          'colorScheme': TileColorScheme.blue.name,
          'soundEnabled': true,
          'vibrationEnabled': true,
        });
      }

      return Right(settings);
    } catch (e) {
      return Left(CacheFailure('Failed to load settings: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      await _localDataSource.saveSettings(settings);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save settings: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllData() async {
    try {
      await _localDataSource.clearAllData();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to clear data: $e'));
    }
  }
}
