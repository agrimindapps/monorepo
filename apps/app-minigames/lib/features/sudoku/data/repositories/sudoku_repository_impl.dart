import 'package:core/core.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/high_score_entity.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/sudoku_statistics.dart';
import '../../domain/repositories/sudoku_repository.dart';
import '../datasources/sudoku_local_datasource.dart';
import '../models/high_score_model.dart';
import '../models/achievement_model.dart';
import '../models/sudoku_statistics_model.dart';

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

  // ==================== ACHIEVEMENTS ====================

  @override
  Future<Either<Failure, List<SudokuAchievement>>> loadAchievements() async {
    try {
      final data = await _localDataSource.loadAchievements();
      return Right(data.toEntities());
    } on Exception catch (e) {
      return Left(CacheFailure('Failed to load achievements: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAchievements(
    List<SudokuAchievement> achievements,
  ) async {
    try {
      final data = SudokuAchievementsDataModel.fromEntities(achievements);
      await _localDataSource.saveAchievements(data);
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure('Failed to save achievements: ${e.toString()}'));
    }
  }

  // ==================== STATISTICS ====================

  @override
  Future<Either<Failure, SudokuStatistics>> loadStatistics() async {
    try {
      final data = await _localDataSource.loadStatistics();
      return Right(data);
    } on Exception catch (e) {
      return Left(CacheFailure('Failed to load statistics: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveStatistics(
    SudokuStatistics statistics,
  ) async {
    try {
      final data = SudokuStatisticsModel.fromEntity(statistics);
      await _localDataSource.saveStatistics(data);
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure('Failed to save statistics: ${e.toString()}'));
    }
  }
}
