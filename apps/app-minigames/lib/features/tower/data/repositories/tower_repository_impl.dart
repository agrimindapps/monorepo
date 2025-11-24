import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/high_score.dart';
import '../../domain/repositories/tower_repository.dart';
import '../datasources/tower_local_data_source.dart';

/// Implementation of TowerRepository
/// Handles data operations and converts exceptions to failures
class TowerRepositoryImpl implements TowerRepository {
  final TowerLocalDataSource localDataSource;

  TowerRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, HighScore>> getHighScore() async {
    try {
      final highScore = await localDataSource.getHighScore();
      return Right(highScore);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to load high score'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore(int score) async {
    try {
      await localDataSource.saveHighScore(score);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Failed to save high score'));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
