import '../entities/achievement.dart';
import '../entities/flappy_statistics.dart';
import '../entities/enums.dart';

/// Service for checking and updating Flappy Bird achievements
class FlappyAchievementService {
  const FlappyAchievementService();

  /// Check achievements based on current stats and return updated list
  List<FlappyAchievement> checkAchievements({
    required FlappyStatistics stats,
    required List<FlappyAchievement> currentAchievements,
  }) {
    final updatedAchievements = <FlappyAchievement>[];

    for (final def in FlappyAchievementDefinitions.all) {
      final current = currentAchievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () => FlappyAchievement(id: def.id),
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
  List<FlappyAchievement> checkEndGameAchievements({
    required FlappyDifficulty difficulty,
    required FlappyGameMode gameMode,
    required FlappySessionStats sessionStats,
    required FlappyStatistics stats,
    required int score,
    required bool survived, // For Time Attack: survived to end
  }) {
    var achievements = <FlappyAchievement>[];

    // Initialize with all achievements
    for (final def in FlappyAchievementDefinitions.all) {
      achievements.add(FlappyAchievement(id: def.id));
    }

    // First game achievement
    if (stats.totalGamesPlayed >= 1) {
      achievements = _unlockAchievement(achievements, 'first_game');
    }

    // First pipe achievement
    if (score >= 1 || stats.totalPipesPassed >= 1) {
      achievements = _unlockAchievement(achievements, 'first_pipe');
    }

    // Score achievements (single game)
    if (score >= 5) {
      achievements = _unlockAchievement(achievements, 'pipes_5');
    }
    if (score >= 10) {
      achievements = _unlockAchievement(achievements, 'score_10');
    }
    if (score >= 25) {
      achievements = _unlockAchievement(achievements, 'score_25');
    }
    if (score >= 50) {
      achievements = _unlockAchievement(achievements, 'score_50');
    }
    if (score >= 75) {
      achievements = _unlockAchievement(achievements, 'score_75');
    }
    if (score >= 100) {
      achievements = _unlockAchievement(achievements, 'score_100');
    }

    // Difficulty-specific achievements
    switch (difficulty) {
      case FlappyDifficulty.easy:
        if (score >= 10) {
          achievements = _unlockAchievement(achievements, 'easy_10');
        }
        if (score >= 50) {
          achievements = _unlockAchievement(achievements, 'easy_50');
        }
        break;
      case FlappyDifficulty.medium:
        if (score >= 10) {
          achievements = _unlockAchievement(achievements, 'medium_10');
        }
        if (score >= 25) {
          achievements = _unlockAchievement(achievements, 'medium_25');
        }
        break;
      case FlappyDifficulty.hard:
        if (score >= 10) {
          achievements = _unlockAchievement(achievements, 'hard_10');
        }
        if (score >= 15) {
          achievements = _unlockAchievement(achievements, 'hard_15');
        }
        if (score >= 50) {
          achievements = _unlockAchievement(achievements, 'perfect_hard');
        }
        break;
    }

    // Game mode achievements
    switch (gameMode) {
      case FlappyGameMode.timeAttack:
        if (survived) {
          achievements = _unlockAchievement(achievements, 'time_attack_survive');
        }
        break;
      case FlappyGameMode.speedRun:
        if (score >= 50) {
          achievements = _unlockAchievement(achievements, 'speed_run_50');
        }
        break;
      case FlappyGameMode.nightMode:
        if (score >= 25) {
          achievements = _unlockAchievement(achievements, 'night_mode_25');
        }
        break;
      case FlappyGameMode.hardcore:
        if (score >= 10) {
          achievements = _unlockAchievement(achievements, 'hardcore_mode_10');
        }
        break;
      case FlappyGameMode.classic:
        // No special achievements for classic mode
        break;
    }

    // Shield save achievement (secret)
    if (sessionStats.usedShield) {
      achievements = _unlockAchievement(achievements, 'shield_save');
    }

    // Now check cumulative achievements using updated stats
    achievements = checkAchievements(
      stats: stats,
      currentAchievements: achievements,
    );

    return achievements;
  }

  /// Get newly unlocked achievements
  List<FlappyAchievementDefinition> getNewlyUnlocked(
    List<FlappyAchievement> before,
    List<FlappyAchievement> after,
  ) {
    final newlyUnlocked = <FlappyAchievementDefinition>[];

    for (final afterAch in after) {
      if (!afterAch.isUnlocked) continue;

      final beforeAch = before.firstWhere(
        (a) => a.id == afterAch.id,
        orElse: () => FlappyAchievement(id: afterAch.id),
      );

      if (!beforeAch.isUnlocked) {
        newlyUnlocked.add(afterAch.definition);
      }
    }

    return newlyUnlocked;
  }

  /// Calculate XP reward for unlocked achievements
  int calculateXpReward(List<FlappyAchievementDefinition> unlockedAchievements) {
    return unlockedAchievements.fold<int>(
      0,
      (sum, def) => sum + def.rarity.xpReward,
    );
  }

  int _getProgress(String achievementId, FlappyStatistics stats) {
    switch (achievementId) {
      // Beginner achievements
      case 'first_game':
        return stats.totalGamesPlayed >= 1 ? 1 : 0;
      case 'first_pipe':
        return stats.totalPipesPassed >= 1 ? 1 : 0;
      case 'pipes_5':
        // Single game - handled in checkEndGameAchievements
        return 0;
      case 'games_10':
        return stats.totalGamesPlayed;
      case 'games_50':
        return stats.totalGamesPlayed;
      case 'games_100':
        return stats.totalGamesPlayed;

      // Scoring achievements - cumulative
      case 'total_score_500':
        return stats.totalScore;
      case 'total_score_1000':
        return stats.totalScore;
      case 'total_pipes_500':
        return stats.totalPipesPassed;

      // Streak achievements
      case 'streak_3':
        return stats.bestStreak5Plus;
      case 'streak_5':
        return stats.bestStreak10Plus;
      case 'streak_10':
        return stats.bestStreak;
      case 'beat_highscore_5':
        return stats.timesBeatenHighScore;
      case 'beat_highscore_10':
        return stats.timesBeatenHighScore;

      // Special achievements - cumulative
      case 'close_call_10':
        return stats.closeCallsCount;
      case 'total_flaps_1000':
        return stats.totalFlaps;
      case 'play_time_30min':
        return stats.totalSecondsPlayed;
      case 'powerup_collector':
        return stats.powerUpsCollected;

      // Single-game achievements return 0 here (handled in checkEndGameAchievements)
      default:
        return 0;
    }
  }

  List<FlappyAchievement> _unlockAchievement(
    List<FlappyAchievement> achievements,
    String id,
  ) {
    final index = achievements.indexWhere((a) => a.id == id);
    if (index == -1) {
      // Add new achievement if not exists
      if (!FlappyAchievementDefinitions.exists(id)) {
        return achievements;
      }
      final def = FlappyAchievementDefinitions.getById(id);
      return [
        ...achievements,
        FlappyAchievement(
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
