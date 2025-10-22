import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score.dart';
import '../../domain/repositories/caca_palavra_repository.dart';
import '../datasources/caca_palavra_local_data_source.dart';

/// Implementation of CacaPalavraRepository using local data source
class CacaPalavraRepositoryImpl implements CacaPalavraRepository {
  final CacaPalavraLocalDataSource localDataSource;

  CacaPalavraRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, HighScore>> loadHighScore() async {
    try {
      final highScore = await localDataSource.loadHighScore();
      return Right(highScore);
    } catch (e) {
      return Left(CacheFailure('Failed to load high score: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveHighScore(HighScore highScore) async {
    try {
      // Convert to model
      final model = highScore as dynamic;
      await localDataSource.saveHighScore(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save high score: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableWords() async {
    try {
      final words = await localDataSource.getAvailableWords();
      return Right(words);
    } catch (e) {
      return Left(CacheFailure('Failed to get available words: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDifficulty(GameDifficulty difficulty) async {
    try {
      await localDataSource.saveDifficulty(difficulty);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save difficulty: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, GameDifficulty>> loadDifficulty() async {
    try {
      final difficulty = await localDataSource.loadDifficulty();
      return Right(difficulty);
    } catch (e) {
      return Left(CacheFailure('Failed to load difficulty: ${e.toString()}'));
    }
  }
}
