// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Core imports:
import 'package:app_minigames/core/error/exceptions.dart';

// Domain imports:
import '../../domain/entities/achievement.dart';

// Data imports:
import '../models/high_score_model.dart';
import '../models/snake_statistics_model.dart';
import '../models/player_level_model.dart';
import '../models/snake_settings_model.dart';
import '../models/achievement_model.dart';

/// Interface for snake local data source
abstract class SnakeLocalDataSource {
  /// Load high score
  Future<HighScoreModel> loadHighScore();

  /// Save high score
  Future<void> saveHighScore(int score);

  /// Load statistics
  Future<SnakeStatisticsModel> loadStatistics();

  /// Save statistics
  Future<void> saveStatistics(SnakeStatisticsModel stats);

  /// Load player level
  Future<PlayerLevelModel> loadPlayerLevel();

  /// Save player level
  Future<void> savePlayerLevel(PlayerLevelModel level);

  /// Load settings
  Future<SnakeSettingsModel> loadSettings();

  /// Save settings
  Future<void> saveSettings(SnakeSettingsModel settings);

  /// Record game end with all statistics
  Future<void> recordGameEnd({
    required int score,
    required int snakeLength,
    required int durationSeconds,
    required String deathType,
    required String difficulty,
    required String gameMode,
    required Map<String, int> powerUpsCollected,
    required int foodEaten,
  });

  /// Load achievements
  Future<AchievementsDataModel> loadAchievements();

  /// Save achievements
  Future<void> saveAchievements(AchievementsDataModel achievements);

  /// Unlock a single achievement
  Future<void> unlockAchievement(String id);

  /// Update achievement progress
  Future<void> updateAchievementProgress(String id, int progress);
}

/// Implementation of snake local data source
class SnakeLocalDataSourceImpl implements SnakeLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _highScoreKey = 'snake_high_score';
  static const String _statisticsKey = 'snake_statistics';
  static const String _playerLevelKey = 'snake_player_level';
  static const String _settingsKey = 'snake_settings';
  static const String _achievementsKey = 'snake_achievements';

  SnakeLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<HighScoreModel> loadHighScore() async {
    try {
      final score = sharedPreferences.getInt(_highScoreKey) ?? 0;
      return HighScoreModel(score: score);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveHighScore(int score) async {
    try {
      await sharedPreferences.setInt(_highScoreKey, score);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<SnakeStatisticsModel> loadStatistics() async {
    try {
      final jsonString = sharedPreferences.getString(_statisticsKey);
      if (jsonString == null) {
        return SnakeStatisticsModel.empty();
      }
      return SnakeStatisticsModel.fromJsonString(jsonString);
    } catch (e) {
      return SnakeStatisticsModel.empty();
    }
  }

  @override
  Future<void> saveStatistics(SnakeStatisticsModel stats) async {
    try {
      await sharedPreferences.setString(_statisticsKey, stats.toJsonString());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<PlayerLevelModel> loadPlayerLevel() async {
    try {
      final jsonString = sharedPreferences.getString(_playerLevelKey);
      if (jsonString == null) {
        return PlayerLevelModel.empty();
      }
      return PlayerLevelModel.fromJsonString(jsonString);
    } catch (e) {
      return PlayerLevelModel.empty();
    }
  }

  @override
  Future<void> savePlayerLevel(PlayerLevelModel level) async {
    try {
      await sharedPreferences.setString(_playerLevelKey, level.toJsonString());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<SnakeSettingsModel> loadSettings() async {
    try {
      final jsonString = sharedPreferences.getString(_settingsKey);
      if (jsonString == null) {
        return SnakeSettingsModel.defaults();
      }
      return SnakeSettingsModel.fromJsonString(jsonString);
    } catch (e) {
      return SnakeSettingsModel.defaults();
    }
  }

  @override
  Future<void> saveSettings(SnakeSettingsModel settings) async {
    try {
      await sharedPreferences.setString(_settingsKey, settings.toJsonString());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> recordGameEnd({
    required int score,
    required int snakeLength,
    required int durationSeconds,
    required String deathType,
    required String difficulty,
    required String gameMode,
    required Map<String, int> powerUpsCollected,
    required int foodEaten,
  }) async {
    try {
      // Load current statistics
      final stats = await loadStatistics();

      // Update power-ups by type
      final newPowerUpsByType = Map<String, int>.from(stats.powerUpsByType);
      for (final entry in powerUpsCollected.entries) {
        newPowerUpsByType[entry.key] =
            (newPowerUpsByType[entry.key] ?? 0) + entry.value;
      }

      // Update deaths by type
      final newDeathsByType = Map<String, int>.from(stats.deathsByType);
      newDeathsByType[deathType] = (newDeathsByType[deathType] ?? 0) + 1;

      // Calculate win streak (if score > previous best)
      int newCurrentStreak = stats.currentWinStreak;
      int newBestStreak = stats.bestWinStreak;
      if (score > stats.highestScore) {
        newCurrentStreak++;
        if (newCurrentStreak > newBestStreak) {
          newBestStreak = newCurrentStreak;
        }
      } else {
        newCurrentStreak = 0;
      }

      // Update wins by difficulty
      int newGamesWonEasy = stats.gamesWonEasy;
      int newGamesWonMedium = stats.gamesWonMedium;
      int newGamesWonHard = stats.gamesWonHard;
      if (score > 0) {
        switch (difficulty) {
          case 'easy':
            newGamesWonEasy++;
            break;
          case 'medium':
            newGamesWonMedium++;
            break;
          case 'hard':
            newGamesWonHard++;
            break;
        }
      }

      final totalPowerUpsThisGame = powerUpsCollected.values.fold<int>(
        0,
        (sum, count) => sum + count,
      );

      // Create updated statistics
      final newStats = SnakeStatisticsModel(
        totalGamesPlayed: stats.totalGamesPlayed + 1,
        totalFoodEaten: stats.totalFoodEaten + foodEaten,
        totalPowerUpsCollected: stats.totalPowerUpsCollected + totalPowerUpsThisGame,
        totalSecondsPlayed: stats.totalSecondsPlayed + durationSeconds,
        longestSnake:
            snakeLength > stats.longestSnake ? snakeLength : stats.longestSnake,
        highestScore: score > stats.highestScore ? score : stats.highestScore,
        totalDeaths: stats.totalDeaths + 1,
        powerUpsByType: newPowerUpsByType,
        deathsByType: newDeathsByType,
        gamesWonHard: newGamesWonHard,
        gamesWonMedium: newGamesWonMedium,
        gamesWonEasy: newGamesWonEasy,
        currentWinStreak: newCurrentStreak,
        bestWinStreak: newBestStreak,
        lastPlayedAt: DateTime.now(),
      );

      await saveStatistics(newStats);

      // Update high score if needed
      if (score > stats.highestScore) {
        await saveHighScore(score);
      }

      // Calculate and add XP
      final playerLevel = await loadPlayerLevel();
      final xpGained = _calculateXpForGame(
        score: score,
        snakeLength: snakeLength,
        survivalSeconds: durationSeconds,
        difficulty: difficulty,
        powerUpsCollected: totalPowerUpsThisGame,
      );
      final newPlayerLevel = PlayerLevelModel(
        totalXp: playerLevel.totalXp + xpGained,
      );
      await savePlayerLevel(newPlayerLevel);
    } catch (e) {
      throw CacheException();
    }
  }

  int _calculateXpForGame({
    required int score,
    required int snakeLength,
    required int survivalSeconds,
    required String difficulty,
    required int powerUpsCollected,
  }) {
    int baseXp = score * 2;
    int lengthBonus = snakeLength * 5;
    int survivalBonus = survivalSeconds ~/ 10;
    int powerUpBonus = powerUpsCollected * 10;

    double difficultyMultiplier = switch (difficulty) {
      'easy' => 1.0,
      'medium' => 1.5,
      'hard' => 2.0,
      _ => 1.0,
    };

    return ((baseXp + lengthBonus + survivalBonus + powerUpBonus) *
            difficultyMultiplier)
        .round();
  }

  @override
  Future<AchievementsDataModel> loadAchievements() async {
    try {
      final jsonString = sharedPreferences.getString(_achievementsKey);
      if (jsonString == null) {
        return AchievementsDataModel.empty();
      }
      return AchievementsDataModel.fromJsonString(jsonString);
    } catch (e) {
      return AchievementsDataModel.empty();
    }
  }

  @override
  Future<void> saveAchievements(AchievementsDataModel achievements) async {
    try {
      await sharedPreferences.setString(
        _achievementsKey,
        achievements.toJsonString(),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> unlockAchievement(String id) async {
    try {
      final data = await loadAchievements();
      final achievements = List<AchievementModel>.from(data.achievements);

      final index = achievements.indexWhere((a) => a.id == id);
      if (index != -1) {
        achievements[index] = achievements[index].copyWith(
          isUnlocked: true,
          unlockedAtTimestamp: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        achievements.add(AchievementModel(
          id: id,
          isUnlocked: true,
          unlockedAtTimestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }

      final newData = AchievementsDataModel(
        achievements: achievements,
        totalXpFromAchievements: _calculateTotalXp(achievements),
        lastUpdatedTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await saveAchievements(newData);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateAchievementProgress(String id, int progress) async {
    try {
      final data = await loadAchievements();
      final achievements = List<AchievementModel>.from(data.achievements);

      final index = achievements.indexWhere((a) => a.id == id);
      if (index != -1) {
        achievements[index] = achievements[index].copyWith(
          currentProgress: progress,
        );
      } else {
        achievements.add(AchievementModel(
          id: id,
          currentProgress: progress,
        ));
      }

      final newData = AchievementsDataModel(
        achievements: achievements,
        totalXpFromAchievements: _calculateTotalXp(achievements),
        lastUpdatedTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await saveAchievements(newData);
    } catch (e) {
      throw CacheException();
    }
  }

  int _calculateTotalXp(List<AchievementModel> achievements) {
    int total = 0;
    for (final achievement in achievements) {
      if (achievement.isUnlocked) {
        try {
          final def =
              AchievementDefinitions.getById(achievement.id);
          total += def.rarity.xpReward;
        } catch (_) {
          // Achievement definition not found, skip
        }
      }
    }
    return total;
  }
}
