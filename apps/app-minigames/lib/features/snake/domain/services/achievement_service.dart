// Domain imports:
import '../entities/achievement.dart';
import '../entities/snake_statistics.dart';
import '../entities/player_level.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Service for checking and updating achievements
class AchievementService {
  const AchievementService();

  /// Check achievements based on current stats and return updated list
  List<Achievement> checkAchievements({
    required SnakeStatistics stats,
    required PlayerLevel level,
    required List<Achievement> currentAchievements,
    SnakeGameState? currentGame,
  }) {
    final updatedAchievements = <Achievement>[];

    for (final def in AchievementDefinitions.all) {
      final current = currentAchievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () => Achievement(id: def.id),
      );

      // Skip already unlocked
      if (current.isUnlocked) {
        updatedAchievements.add(current);
        continue;
      }

      // Calculate progress based on achievement type
      final progress = _getProgress(
        def.id,
        stats,
        level,
        currentGame,
        currentAchievements,
      );

      updatedAchievements.add(current.withProgress(progress));
    }

    return updatedAchievements;
  }

  /// Check achievements after game end
  List<Achievement> checkEndGameAchievements({
    required int finalScore,
    required int finalLength,
    required int survivalSeconds,
    required SnakeGameMode gameMode,
    required SnakeDifficulty difficulty,
    required int powerUpsUsedThisGame,
    required Map<String, int> powerUpsByType,
    required bool usedNoPowerUps,
    required int activePowerUpsAtOnce,
    required bool shieldSavedFromDeath,
    required SnakeStatistics stats,
    required PlayerLevel level,
    required List<Achievement> currentAchievements,
  }) {
    var achievements = List<Achievement>.from(currentAchievements);

    // Score achievements (single game)
    achievements = _checkAndUpdateSingle(achievements, 'score_25', finalScore);
    achievements = _checkAndUpdateSingle(achievements, 'score_50', finalScore);
    achievements = _checkAndUpdateSingle(achievements, 'score_100', finalScore);
    achievements = _checkAndUpdateSingle(achievements, 'score_200', finalScore);
    achievements = _checkAndUpdateSingle(achievements, 'score_500', finalScore);

    // Survival achievements (single game)
    achievements = _checkAndUpdateSingle(achievements, 'survive_30', survivalSeconds);
    achievements = _checkAndUpdateSingle(achievements, 'survive_60', survivalSeconds);
    achievements = _checkAndUpdateSingle(achievements, 'survive_120', survivalSeconds);
    achievements = _checkAndUpdateSingle(achievements, 'survive_300', survivalSeconds);

    // Length achievements (single game)
    achievements = _checkAndUpdateSingle(achievements, 'length_10', finalLength);
    achievements = _checkAndUpdateSingle(achievements, 'length_25', finalLength);
    achievements = _checkAndUpdateSingle(achievements, 'length_50', finalLength);
    achievements = _checkAndUpdateSingle(achievements, 'length_100', finalLength);

    // Mode-specific achievements
    if (gameMode == SnakeGameMode.classic) {
      achievements = _checkAndUpdateSingle(achievements, 'win_classic', finalScore);
    }
    if (gameMode == SnakeGameMode.survival) {
      achievements = _checkAndUpdateSingle(achievements, 'win_survival', finalScore);
    }
    if (gameMode == SnakeGameMode.timeAttack) {
      achievements = _checkAndUpdateSingle(achievements, 'win_time_attack', finalScore);
    }
    if (gameMode == SnakeGameMode.endless) {
      achievements = _checkAndUpdateSingle(achievements, 'win_endless', finalScore);
    }
    if (difficulty == SnakeDifficulty.hard && finalScore >= 50) {
      achievements = _checkAndUpdateSingle(achievements, 'win_hard', finalScore);
    }

    // Special achievements
    if (usedNoPowerUps && finalScore >= 50) {
      achievements = _unlockAchievement(achievements, 'no_power_up_50');
    }
    if (activePowerUpsAtOnce >= 3) {
      achievements = _unlockAchievement(achievements, 'triple_power_up');
    }
    if (shieldSavedFromDeath) {
      achievements = _unlockAchievement(achievements, 'close_call');
    }
    if (survivalSeconds < 30 && finalScore >= 25) {
      achievements = _unlockAchievement(achievements, 'speed_run');
    }

    // Now check cumulative achievements using updated stats
    achievements = checkAchievements(
      stats: stats,
      level: level,
      currentAchievements: achievements,
    );

    // Check for completionist (all other achievements unlocked)
    final unlockedCount = achievements.where((a) => a.isUnlocked && a.id != 'all_achievements').length;
    final totalOther = AchievementDefinitions.all.where((d) => d.id != 'all_achievements').length;
    if (unlockedCount >= totalOther) {
      achievements = _unlockAchievement(achievements, 'all_achievements');
    }

    return achievements;
  }

  /// Get newly unlocked achievements
  List<AchievementDefinition> getNewlyUnlocked(
    List<Achievement> before,
    List<Achievement> after,
  ) {
    final newlyUnlocked = <AchievementDefinition>[];

    for (final afterAch in after) {
      if (!afterAch.isUnlocked) continue;

      final beforeAch = before.firstWhere(
        (a) => a.id == afterAch.id,
        orElse: () => Achievement(id: afterAch.id),
      );

      if (!beforeAch.isUnlocked) {
        newlyUnlocked.add(afterAch.definition);
      }
    }

    return newlyUnlocked;
  }

  /// Calculate XP reward for unlocked achievements
  int calculateXpReward(List<AchievementDefinition> unlockedAchievements) {
    return unlockedAchievements.fold<int>(
      0,
      (sum, def) => sum + def.rarity.xpReward,
    );
  }

  int _getProgress(
    String achievementId,
    SnakeStatistics stats,
    PlayerLevel level,
    SnakeGameState? currentGame,
    List<Achievement> currentAchievements,
  ) {
    switch (achievementId) {
      // Beginner achievements
      case 'first_food':
        return stats.totalFoodEaten >= 1 ? 1 : 0;
      case 'first_game':
        return stats.totalGamesPlayed >= 1 ? 1 : 0;
      case 'first_power_up':
        return stats.totalPowerUpsCollected >= 1 ? 1 : 0;
      case 'games_10':
        return stats.totalGamesPlayed;
      case 'games_50':
        return stats.totalGamesPlayed;
      case 'games_100':
        return stats.totalGamesPlayed;
      case 'games_500':
        return stats.totalGamesPlayed;
      case 'play_time_60':
        return stats.totalSecondsPlayed;

      // Score achievements (cumulative)
      case 'total_score_1000':
        return _calculateTotalScore(stats);

      // Power-up achievements
      case 'power_ups_10':
        return stats.totalPowerUpsCollected;
      case 'power_ups_50':
        return stats.totalPowerUpsCollected;
      case 'power_ups_100':
        return stats.totalPowerUpsCollected;
      case 'use_all_power_ups':
        return _countUniquePowerUpsUsed(stats);
      case 'ghost_master':
        return stats.powerUpsByType['ghostMode'] ?? 0;
      case 'shield_master':
        return stats.powerUpsByType['shield'] ?? 0;
      case 'speed_demon':
        return stats.powerUpsByType['speedBoost'] ?? 0;
      case 'double_points_master':
        return _calculateDoublePointsScore(stats);

      // Mode achievements
      case 'all_modes_played':
        return _countModesPlayed(stats);

      // Food eaten in one session (tracked as no_death_10_food)
      case 'no_death_10_food':
        return currentGame?.foodEatenThisGame ?? 0;

      // Master achievements
      case 'level_50':
        return level.currentLevel;
      case 'total_food_1000':
        return stats.totalFoodEaten;
      case 'all_achievements':
        return currentAchievements
            .where((a) => a.isUnlocked && a.id != 'all_achievements')
            .length;

      // Single-game achievements return 0 here (handled in checkEndGameAchievements)
      default:
        return 0;
    }
  }

  int _calculateTotalScore(SnakeStatistics stats) {
    // Approximate total score based on food eaten (10 points per food)
    return stats.totalFoodEaten * 10;
  }

  int _countUniquePowerUpsUsed(SnakeStatistics stats) {
    return stats.powerUpsByType.keys
        .where((key) => (stats.powerUpsByType[key] ?? 0) > 0)
        .length;
  }

  int _calculateDoublePointsScore(SnakeStatistics stats) {
    // Estimate: each double points usage averages ~10 bonus points
    return (stats.powerUpsByType['doublePoints'] ?? 0) * 10;
  }

  int _countModesPlayed(SnakeStatistics stats) {
    // This requires tracking which modes were played
    // For now, we estimate based on total games
    // A proper implementation would track modes separately
    int count = 0;
    if (stats.totalGamesPlayed > 0) count++; // At least classic
    // Additional modes would be tracked in extended stats
    return count.clamp(0, 4);
  }

  List<Achievement> _checkAndUpdateSingle(
    List<Achievement> achievements,
    String id,
    int value,
  ) {
    final index = achievements.indexWhere((a) => a.id == id);
    if (index == -1) return achievements;

    final current = achievements[index];
    if (current.isUnlocked) return achievements;

    final updated = current.withProgress(value);
    return [
      ...achievements.sublist(0, index),
      updated,
      ...achievements.sublist(index + 1),
    ];
  }

  List<Achievement> _unlockAchievement(
    List<Achievement> achievements,
    String id,
  ) {
    final index = achievements.indexWhere((a) => a.id == id);
    if (index == -1) {
      // Add new achievement if not exists
      final def = AchievementDefinitions.getById(id);
      return [
        ...achievements,
        Achievement(
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
