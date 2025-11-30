import 'package:core/core.dart';
import '../entities/high_score_entity.dart';
import '../entities/enums.dart';
import '../entities/achievement.dart';
import '../entities/sudoku_statistics.dart';

abstract class SudokuRepository {
  /// Load high score for a specific difficulty
  Future<Either<Failure, HighScoreEntity>> loadHighScore(
    GameDifficulty difficulty,
  );

  /// Save high score for a specific difficulty
  Future<Either<Failure, void>> saveHighScore(HighScoreEntity highScore);

  /// Get all high scores (for all difficulties)
  Future<Either<Failure, List<HighScoreEntity>>> getAllHighScores();

  /// Clear all high scores
  Future<Either<Failure, void>> clearAllHighScores();

  // ==================== ACHIEVEMENTS ====================

  /// Load achievements
  Future<Either<Failure, List<SudokuAchievement>>> loadAchievements();

  /// Save achievements
  Future<Either<Failure, void>> saveAchievements(
    List<SudokuAchievement> achievements,
  );

  // ==================== STATISTICS ====================

  /// Load statistics
  Future<Either<Failure, SudokuStatistics>> loadStatistics();

  /// Save statistics
  Future<Either<Failure, void>> saveStatistics(SudokuStatistics statistics);
}
