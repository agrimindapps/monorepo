// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/exceptions.dart';
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../../domain/entities/high_score.dart';
import '../../domain/repositories/snake_repository.dart';

// Data imports:
import '../datasources/snake_local_data_source.dart';

/// Implementation of SnakeRepository
class SnakeRepositoryImpl implements SnakeRepository {
  final SnakeLocalDataSource localDataSource;

  SnakeRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, HighScore>> loadHighScore() async {
    try {
      final highScore = await localDataSource.loadHighScore();
      return Right(highScore);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore(int score) async {
    try {
      await localDataSource.saveHighScore(score);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
