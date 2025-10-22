// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Domain imports:
import '../../domain/entities/high_score_entity.dart';
import '../../domain/repositories/flappbird_repository.dart';

// Data imports:
import '../datasources/flappbird_local_datasource.dart';
import '../models/high_score_model.dart';

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
}
