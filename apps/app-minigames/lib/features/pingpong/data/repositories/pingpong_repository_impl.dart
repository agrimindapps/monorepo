import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/pingpong_repository.dart';
import '../datasources/pingpong_local_datasource.dart';
import '../models/high_score_model.dart';

class PingpongRepositoryImpl implements PingpongRepository {
  final PingpongLocalDataSource localDataSource;

  PingpongRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, HighScoreEntity?>> getHighScore(
      GameDifficulty difficulty) async {
    try {
      final highScore = await localDataSource.getHighScore(difficulty);
      return Right(highScore);
    } catch (e) {
      return Left(CacheFailure('Failed to get high score: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore(
      HighScoreEntity highScore) async {
    try {
      final model = HighScoreModel.fromEntity(highScore);
      await localDataSource.saveHighScore(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save high score: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearHighScores() async {
    try {
      await localDataSource.clearHighScores();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear high scores: $e'));
    }
  }
}
