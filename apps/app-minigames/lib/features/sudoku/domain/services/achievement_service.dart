import '../entities/achievement.dart';
import '../entities/sudoku_statistics.dart';
import '../entities/enums.dart';

/// Service for checking and updating Sudoku achievements
class SudokuAchievementService {
  const SudokuAchievementService();

  /// Check achievements based on current stats and return updated list
  List<SudokuAchievement> checkAchievements({
    required SudokuStatistics stats,
    required List<SudokuAchievement> currentAchievements,
  }) {
    final updatedAchievements = <SudokuAchievement>[];

    for (final def in SudokuAchievementDefinitions.all) {
      final current = currentAchievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () => SudokuAchievement(id: def.id),
      );

      // Skip already unlocked
      if (current.isUnlocked) {
        updatedAchievements.add(current);
        continue;
      }

      // Calculate progress based on achievement type
      final progress = _getProgress(def.id, stats);
      updatedAchievements.add(current.withProgress(progress));
    }

    return updatedAchievements;
  }

  /// Check achievements after game end
  List<SudokuAchievement> checkEndGameAchievements({
    required GameDifficulty difficulty,
    required SudokuSessionStats sessionStats,
    required SudokuStatistics stats,
    required List<SudokuAchievement> currentAchievements,
    required bool won,
    required int gameTimeSeconds,
  }) {
    var achievements = List<SudokuAchievement>.from(currentAchievements);

    if (won) {
      // First puzzle achievement
      achievements = _unlockAchievement(achievements, 'first_puzzle');

      // Difficulty-specific completions
      switch (difficulty) {
        case GameDifficulty.easy:
          achievements = _unlockAchievement(achievements, 'easy_complete');
          // Speed achievements for easy
          if (gameTimeSeconds < 300) {
            // 5 min
            achievements = _unlockAchievement(achievements, 'easy_5min');
          }
          if (gameTimeSeconds < 180) {
            // 3 min
            achievements = _unlockAchievement(achievements, 'easy_3min');
          }
          if (gameTimeSeconds < 120) {
            // 2 min
            achievements = _unlockAchievement(achievements, 'easy_2min');
          }
          break;
        case GameDifficulty.medium:
          achievements = _unlockAchievement(achievements, 'medium_complete');
          // Speed achievements for medium
          if (gameTimeSeconds < 600) {
            // 10 min
            achievements = _unlockAchievement(achievements, 'medium_10min');
          }
          if (gameTimeSeconds < 420) {
            // 7 min
            achievements = _unlockAchievement(achievements, 'medium_7min');
          }
          break;
        case GameDifficulty.hard:
          achievements = _unlockAchievement(achievements, 'hard_complete');
          // Speed achievements for hard
          if (gameTimeSeconds < 1200) {
            // 20 min
            achievements = _unlockAchievement(achievements, 'hard_20min');
          }
          if (gameTimeSeconds < 900) {
            // 15 min
            achievements = _unlockAchievement(achievements, 'hard_15min');
          }
          if (gameTimeSeconds < 600) {
            // 10 min
            achievements = _unlockAchievement(achievements, 'hard_10min');
          }

          // Hard specific precision achievements (secret)
          if (sessionStats.isPerfectGame) {
            achievements = _unlockAchievement(achievements, 'hard_perfect');
          }
          if (sessionStats.isNoHintGame) {
            achievements = _unlockAchievement(achievements, 'hard_no_hints');
          }

          // Ultimate achievement (secret)
          if (sessionStats.isPerfectNoHintGame && gameTimeSeconds < 600) {
            achievements = _unlockAchievement(achievements, 'ultimate');
          }

          // Minimalist achievement
          if (sessionStats.notesPlacedThisGame < 10) {
            achievements = _unlockAchievement(achievements, 'minimalist');
          }
          break;
      }

      // Precision achievements
      if (sessionStats.isPerfectGame) {
        achievements = _unlockAchievement(achievements, 'no_mistakes_1');
      }
      if (sessionStats.isNoHintGame) {
        achievements = _unlockAchievement(achievements, 'no_hints_1');
      }
      if (sessionStats.isPerfectNoHintGame) {
        achievements = _unlockAchievement(achievements, 'perfect_game');
      }
    }

    // Notes mode usage (regardless of win)
    if (sessionStats.usedNotesMode) {
      achievements = _unlockAchievement(achievements, 'first_note');
    }

    // Hint usage (regardless of win)
    if (sessionStats.hintsUsedThisGame > 0) {
      achievements = _unlockAchievement(achievements, 'first_hint');
    }

    // Now check cumulative achievements using updated stats
    achievements = checkAchievements(
      stats: stats,
      currentAchievements: achievements,
    );

    return achievements;
  }

  /// Get newly unlocked achievements
  List<SudokuAchievementDefinition> getNewlyUnlocked(
    List<SudokuAchievement> before,
    List<SudokuAchievement> after,
  ) {
    final newlyUnlocked = <SudokuAchievementDefinition>[];

    for (final afterAch in after) {
      if (!afterAch.isUnlocked) continue;

      final beforeAch = before.firstWhere(
        (a) => a.id == afterAch.id,
        orElse: () => SudokuAchievement(id: afterAch.id),
      );

      if (!beforeAch.isUnlocked) {
        newlyUnlocked.add(afterAch.definition);
      }
    }

    return newlyUnlocked;
  }

  /// Calculate XP reward for unlocked achievements
  int calculateXpReward(List<SudokuAchievementDefinition> unlockedAchievements) {
    return unlockedAchievements.fold<int>(
      0,
      (sum, def) => sum + def.rarity.xpReward,
    );
  }

  int _getProgress(String achievementId, SudokuStatistics stats) {
    switch (achievementId) {
      // Beginner achievements
      case 'first_puzzle':
        return stats.totalPuzzlesCompleted >= 1 ? 1 : 0;
      case 'first_note':
        return stats.totalNotesPlaced >= 1 ? 1 : 0;
      case 'first_hint':
        return stats.totalHintsUsed >= 1 ? 1 : 0;
      case 'puzzles_10':
        return stats.totalPuzzlesCompleted;
      case 'puzzles_50':
        return stats.totalPuzzlesCompleted;
      case 'puzzles_100':
        return stats.totalPuzzlesCompleted;
      case 'puzzles_500':
        return stats.totalPuzzlesCompleted;

      // Streak achievements
      case 'streak_3':
        return stats.bestStreak;
      case 'streak_5':
        return stats.bestStreak;
      case 'streak_10':
        return stats.bestStreak;
      case 'streak_25':
        return stats.bestStreak;
      case 'streak_50':
        return stats.bestStreak;

      // Difficulty achievements
      case 'easy_complete':
        return stats.easyCompleted >= 1 ? 1 : 0;
      case 'medium_complete':
        return stats.mediumCompleted >= 1 ? 1 : 0;
      case 'hard_complete':
        return stats.hardCompleted >= 1 ? 1 : 0;
      case 'all_difficulties':
        return stats.difficultiesCompleted;
      case 'easy_master':
        return stats.easyCompleted;
      case 'medium_master':
        return stats.mediumCompleted;
      case 'hard_master':
        return stats.hardCompleted;

      // Precision achievements - cumulative
      case 'no_mistakes_5':
        return stats.perfectGames;
      case 'no_mistakes_25':
        return stats.perfectGames;
      case 'no_hints_10':
        return stats.noHintGames;
      case 'perfect_10':
        return stats.perfectNoHintGames;

      // Notes achievements
      case 'notes_100':
        return stats.totalNotesPlaced;
      case 'notes_500':
        return stats.totalNotesPlaced;
      case 'notes_1000':
        return stats.totalNotesPlaced;

      // Special achievements
      case 'cells_1000':
        return stats.totalCellsFilled;
      case 'cells_10000':
        return stats.totalCellsFilled;
      case 'hints_100':
        return stats.totalHintsUsed;

      // Single-game achievements return 0 here (handled in checkEndGameAchievements)
      default:
        return 0;
    }
  }

  List<SudokuAchievement> _unlockAchievement(
    List<SudokuAchievement> achievements,
    String id,
  ) {
    final index = achievements.indexWhere((a) => a.id == id);
    if (index == -1) {
      // Add new achievement if not exists
      if (!SudokuAchievementDefinitions.exists(id)) {
        return achievements;
      }
      final def = SudokuAchievementDefinitions.getById(id);
      return [
        ...achievements,
        SudokuAchievement(
          id: id,
          currentProgress: def.target,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ),
      ];
    }

    final current = achievements[index];
    if (current.isUnlocked) return achievements;

    return [
      ...achievements.sublist(0, index),
      current.unlock(),
      ...achievements.sublist(index + 1),
    ];
  }
}
