import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/repositories/sudoku_repository.dart';
import '../datasources/sudoku_local_datasource.dart';
import '../models/high_score_model.dart';

class SudokuRepositoryImpl implements SudokuRepository {
  final SudokuLocalDataSource _localDataSource;

  SudokuRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, HighScoreEntity>> loadHighScore(
    GameDifficulty difficulty,
  ) async {
    try {
      final highScore = await _localDataSource.loadHighScore(difficulty);

      if (highScore == null) {
        // Return initial high score if none exists
        return Right(HighScoreEntity.initial(difficulty));
      }

      return Right(highScore);
    } on Exception catch (e) {
      return Left(CacheFailure('Failed to load high score: ${e.toString()}'));
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
    } on Exception catch (e) {
      return Left(CacheFailure('Failed to save high score: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<HighScoreEntity>>> getAllHighScores() async {
    try {
      final highScores = await _localDataSource.getAllHighScores();
      return Right(highScores);
    } on Exception catch (e) {
      return Left(
        CacheFailure('Failed to load all high scores: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearAllHighScores() async {
    try {
      await _localDataSource.clearAllHighScores();
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        CacheFailure('Failed to clear high scores: ${e.toString()}'),
      );
    }
  }
}
