import '../entities/achievement.dart';
import '../entities/campo_minado_statistics.dart';
import '../entities/enums.dart';
import '../entities/game_state.dart';

/// Service for checking and updating Campo Minado achievements
class CampoMinadoAchievementService {
  const CampoMinadoAchievementService();

  /// Check achievements based on current stats and return updated list
  List<CampoMinadoAchievement> checkAchievements({
    required CampoMinadoStatistics stats,
    required List<CampoMinadoAchievement> currentAchievements,
  }) {
    final updatedAchievements = <CampoMinadoAchievement>[];

    for (final def in CampoMinadoAchievementDefinitions.all) {
      final current = currentAchievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () => CampoMinadoAchievement(id: def.id),
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
  List<CampoMinadoAchievement> checkEndGameAchievements({
    required GameState gameState,
    required GameSessionStats sessionStats,
    required CampoMinadoStatistics stats,
    required List<CampoMinadoAchievement> currentAchievements,
    required bool won,
    required int gameTimeSeconds,
  }) {
    var achievements = List<CampoMinadoAchievement>.from(currentAchievements);
    final difficulty = gameState.difficulty;

    if (won) {
      // First win achievement
      achievements = _unlockAchievement(achievements, 'first_win');

      // Difficulty-specific wins
      switch (difficulty) {
        case Difficulty.beginner:
          achievements = _unlockAchievement(achievements, 'win_beginner');
          // Speed achievements for beginner
          if (gameTimeSeconds < 30) {
            achievements = _unlockAchievement(achievements, 'beginner_30s');
          }
          if (gameTimeSeconds < 20) {
            achievements = _unlockAchievement(achievements, 'beginner_20s');
          }
          break;
        case Difficulty.intermediate:
          achievements = _unlockAchievement(achievements, 'win_intermediate');
          // Speed achievements for intermediate
          if (gameTimeSeconds < 120) {
            achievements = _unlockAchievement(achievements, 'intermediate_120s');
          }
          if (gameTimeSeconds < 90) {
            achievements = _unlockAchievement(achievements, 'intermediate_90s');
          }
          break;
        case Difficulty.expert:
          achievements = _unlockAchievement(achievements, 'win_expert');
          // Speed achievements for expert
          if (gameTimeSeconds < 300) {
            achievements = _unlockAchievement(achievements, 'expert_300s');
          }
          if (gameTimeSeconds < 180) {
            achievements = _unlockAchievement(achievements, 'expert_180s');
          }
          break;
        case Difficulty.custom:
          // No specific achievements for custom
          break;
      }

      // Precision achievements
      if (sessionStats.isPerfectGame) {
        achievements = _unlockAchievement(achievements, 'no_wrong_flags');
      }

      // Perfect flags (used exactly the number of mines)
      if (sessionStats.flagsPlacedThisGame == gameState.config.mines &&
          sessionStats.wrongFlagsThisGame == 0) {
        achievements = _unlockAchievement(achievements, 'perfect_flags');
      }
    }

    // First flag achievement (regardless of win)
    if (sessionStats.flagsPlacedThisGame > 0) {
      achievements = _unlockAchievement(achievements, 'first_flag');
    }

    // First click achievements
    if (sessionStats.firstClickRevealCount >= 5) {
      achievements = _unlockAchievement(achievements, 'first_click_safe');
    }
    if (sessionStats.firstClickRevealCount >= 15) {
      achievements = _unlockAchievement(achievements, 'lucky_first_click');
    }

    // Now check cumulative achievements using updated stats
    achievements = checkAchievements(
      stats: stats,
      currentAchievements: achievements,
    );

    return achievements;
  }

  /// Get newly unlocked achievements
  List<CampoMinadoAchievementDefinition> getNewlyUnlocked(
    List<CampoMinadoAchievement> before,
    List<CampoMinadoAchievement> after,
  ) {
    final newlyUnlocked = <CampoMinadoAchievementDefinition>[];

    for (final afterAch in after) {
      if (!afterAch.isUnlocked) continue;

      final beforeAch = before.firstWhere(
        (a) => a.id == afterAch.id,
        orElse: () => CampoMinadoAchievement(id: afterAch.id),
      );

      if (!beforeAch.isUnlocked) {
        newlyUnlocked.add(afterAch.definition);
      }
    }

    return newlyUnlocked;
  }

  /// Calculate XP reward for unlocked achievements
  int calculateXpReward(List<CampoMinadoAchievementDefinition> unlockedAchievements) {
    return unlockedAchievements.fold<int>(
      0,
      (sum, def) => sum + def.rarity.xpReward,
    );
  }

  int _getProgress(String achievementId, CampoMinadoStatistics stats) {
    switch (achievementId) {
      // Beginner achievements
      case 'first_win':
        return stats.totalWins >= 1 ? 1 : 0;
      case 'first_flag':
        return stats.totalFlagsPlaced >= 1 ? 1 : 0;
      case 'games_10':
        return stats.totalGamesPlayed;
      case 'games_50':
        return stats.totalGamesPlayed;
      case 'games_100':
        return stats.totalGamesPlayed;
      case 'games_500':
        return stats.totalGamesPlayed;

      // Streak achievements
      case 'streak_3':
        return stats.bestGlobalStreak;
      case 'streak_5':
        return stats.bestGlobalStreak;
      case 'streak_10':
        return stats.bestGlobalStreak;
      case 'streak_25':
        return stats.bestGlobalStreak;

      // Difficulty achievements
      case 'win_beginner':
        return stats.beginnerWins >= 1 ? 1 : 0;
      case 'win_intermediate':
        return stats.intermediateWins >= 1 ? 1 : 0;
      case 'win_expert':
        return stats.expertWins >= 1 ? 1 : 0;
      case 'win_all_difficulties':
        return stats.difficultiesWon;
      case 'master_expert':
        return stats.expertWins;

      // Precision achievements
      case 'chord_master_50':
        return stats.totalChordClicks;
      case 'chord_master_200':
        return stats.totalChordClicks;

      // Special achievements
      case 'total_cells_1000':
        return stats.totalCellsRevealed;
      case 'total_cells_10000':
        return stats.totalCellsRevealed;
      case 'total_wins_100':
        return stats.totalWins;

      // Single-game achievements return 0 here (handled in checkEndGameAchievements)
      default:
        return 0;
    }
  }

  List<CampoMinadoAchievement> _unlockAchievement(
    List<CampoMinadoAchievement> achievements,
    String id,
  ) {
    final index = achievements.indexWhere((a) => a.id == id);
    if (index == -1) {
      // Add new achievement if not exists
      if (!CampoMinadoAchievementDefinitions.exists(id)) {
        return achievements;
      }
      final def = CampoMinadoAchievementDefinitions.getById(id);
      return [
        ...achievements,
        CampoMinadoAchievement(
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
