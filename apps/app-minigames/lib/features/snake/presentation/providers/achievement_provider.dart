// Dart imports:
import 'dart:async';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Domain imports:
import '../../domain/entities/achievement.dart';
import '../../domain/entities/snake_statistics.dart';
import '../../domain/entities/player_level.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/enums.dart';
import '../../domain/services/achievement_service.dart';
import '../../data/models/achievement_model.dart';
import 'snake_providers.dart';
import 'snake_extended_providers.dart';

part 'achievement_provider.g.dart';

/// Provider for achievement service
@riverpod
AchievementService achievementService(Ref ref) {
  return const AchievementService();
}

/// Provider for achievements state
@riverpod
class AchievementsNotifier extends _$AchievementsNotifier {
  @override
  FutureOr<List<Achievement>> build() async {
    final dataSource = ref.read(snakeLocalDataSourceProvider);
    final data = await dataSource.loadAchievements();

    // Initialize with all achievement definitions if empty
    if (data.achievements.isEmpty) {
      return AchievementDefinitions.all
          .map((def) => Achievement(id: def.id))
          .toList();
    }

    // Merge saved achievements with definitions (in case new achievements added)
    final savedAchievements = data.toEntities();
    final mergedAchievements = <Achievement>[];

    for (final def in AchievementDefinitions.all) {
      final saved = savedAchievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () => Achievement(id: def.id),
      );
      mergedAchievements.add(saved);
    }

    return mergedAchievements;
  }

  /// Check and update achievements based on current stats
  Future<List<AchievementDefinition>> checkAndUpdateAchievements({
    required SnakeStatistics stats,
    required PlayerLevel level,
    SnakeGameState? currentGame,
  }) async {
    final currentAchievements = state.value ?? [];
    final service = ref.read(achievementServiceProvider);

    final updatedAchievements = service.checkAchievements(
      stats: stats,
      level: level,
      currentAchievements: currentAchievements,
      currentGame: currentGame,
    );

    // Find newly unlocked
    final newlyUnlocked = service.getNewlyUnlocked(
      currentAchievements,
      updatedAchievements,
    );

    // Save if changes
    if (newlyUnlocked.isNotEmpty ||
        _hasProgressChanges(currentAchievements, updatedAchievements)) {
      await _saveAchievements(updatedAchievements);
      state = AsyncValue.data(updatedAchievements);
    }

    return newlyUnlocked;
  }

  /// Process end game and check for achievements
  Future<List<AchievementDefinition>> processEndGame({
    required int finalScore,
    required int finalLength,
    required int survivalSeconds,
    required SnakeGameMode gameMode,
    required SnakeDifficulty difficulty,
    required Map<String, int> powerUpsByType,
    required bool usedNoPowerUps,
    required int activePowerUpsAtOnce,
    required bool shieldSavedFromDeath,
  }) async {
    final currentAchievements = state.value ?? [];
    final service = ref.read(achievementServiceProvider);

    // Get updated stats and level after game
    final statsAsync = await ref.read(snakeStatisticsProvider.future);
    final levelAsync = await ref.read(playerLevelProvider.future);

    final updatedAchievements = service.checkEndGameAchievements(
      finalScore: finalScore,
      finalLength: finalLength,
      survivalSeconds: survivalSeconds,
      gameMode: gameMode,
      difficulty: difficulty,
      powerUpsUsedThisGame: powerUpsByType.values.fold(0, (a, b) => a + b),
      powerUpsByType: powerUpsByType,
      usedNoPowerUps: usedNoPowerUps,
      activePowerUpsAtOnce: activePowerUpsAtOnce,
      shieldSavedFromDeath: shieldSavedFromDeath,
      stats: statsAsync,
      level: levelAsync,
      currentAchievements: currentAchievements,
    );

    // Find newly unlocked
    final newlyUnlocked = service.getNewlyUnlocked(
      currentAchievements,
      updatedAchievements,
    );

    // Save changes
    await _saveAchievements(updatedAchievements);
    state = AsyncValue.data(updatedAchievements);

    // Add XP from achievements
    if (newlyUnlocked.isNotEmpty) {
      final xpReward = service.calculateXpReward(newlyUnlocked);
      if (xpReward > 0) {
        await ref.read(playerLevelProvider.notifier).addXp(xpReward);
      }
    }

    return newlyUnlocked;
  }

  /// Get unlocked achievements
  List<Achievement> get unlockedAchievements {
    return (state.value ?? []).where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  List<Achievement> get lockedAchievements {
    return (state.value ?? []).where((a) => !a.isUnlocked).toList();
  }

  /// Get total XP earned from achievements
  int get totalXpEarned {
    return unlockedAchievements.fold<int>(
      0,
      (sum, a) => sum + a.definition.rarity.xpReward,
    );
  }

  /// Get completion percentage
  double get completionPercent {
    final total = AchievementDefinitions.totalCount;
    if (total == 0) return 0.0;
    return unlockedAchievements.length / total;
  }

  /// Refresh achievements from storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dataSource = ref.read(snakeLocalDataSourceProvider);
      final data = await dataSource.loadAchievements();
      return data.toEntities();
    });
  }

  Future<void> _saveAchievements(List<Achievement> achievements) async {
    final dataSource = ref.read(snakeLocalDataSourceProvider);
    final data = AchievementsDataModel.fromEntities(achievements);
    await dataSource.saveAchievements(data);
  }

  bool _hasProgressChanges(
    List<Achievement> before,
    List<Achievement> after,
  ) {
    for (final afterAch in after) {
      final beforeAch = before.firstWhere(
        (a) => a.id == afterAch.id,
        orElse: () => Achievement(id: afterAch.id),
      );
      if (beforeAch.currentProgress != afterAch.currentProgress) {
        return true;
      }
    }
    return false;
  }
}

/// Provider for achievements by category
@riverpod
List<Achievement> achievementsByCategory(
  Ref ref,
  AchievementCategory category,
) {
  final achievementsAsync = ref.watch(achievementsProvider);
  return achievementsAsync.when(
    data: (achievements) =>
        achievements.where((a) => a.definition.category == category).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for achievements completion percentage
@riverpod
int achievementsCompletionPercent(Ref ref) {
  final achievementsAsync = ref.watch(achievementsProvider);
  return achievementsAsync.when(
    data: (achievements) {
      final total = AchievementDefinitions.totalCount;
      if (total == 0) return 0;
      final unlocked = achievements.where((a) => a.isUnlocked).length;
      return ((unlocked / total) * 100).round();
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for total XP from achievements
@riverpod
int achievementsTotalXp(Ref ref) {
  final achievementsAsync = ref.watch(achievementsProvider);
  return achievementsAsync.when(
    data: (achievements) {
      return achievements
          .where((a) => a.isUnlocked)
          .fold<int>(0, (sum, a) => sum + a.definition.rarity.xpReward);
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for unlocked achievements count
@riverpod
int unlockedAchievementsCount(Ref ref) {
  final achievementsAsync = ref.watch(achievementsProvider);
  return achievementsAsync.when(
    data: (achievements) => achievements.where((a) => a.isUnlocked).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for recently unlocked achievements (last 7 days)
@riverpod
List<Achievement> recentlyUnlockedAchievements(
  Ref ref,
) {
  final achievementsAsync = ref.watch(achievementsProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  return achievementsAsync.when(
    data: (achievements) {
      return achievements
          .where((a) =>
              a.isUnlocked &&
              a.unlockedAt != null &&
              a.unlockedAt!.isAfter(sevenDaysAgo))
          .toList()
        ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for achievement stats summary
@riverpod
AchievementStats achievementStats(Ref ref) {
  final achievementsAsync = ref.watch(achievementsProvider);

  return achievementsAsync.when(
    data: (achievements) {
      final unlocked = achievements.where((a) => a.isUnlocked).toList();
      final totalXp = unlocked.fold<int>(
        0,
        (sum, a) => sum + a.definition.rarity.xpReward,
      );

      // Count by rarity
      final byRarity = <AchievementRarity, int>{};
      for (final rarity in AchievementRarity.values) {
        byRarity[rarity] = unlocked
            .where((a) => a.definition.rarity == rarity)
            .length;
      }

      // Highest rarity unlocked
      AchievementRarity? highestRarity;
      for (final rarity in AchievementRarity.values.reversed) {
        if ((byRarity[rarity] ?? 0) > 0) {
          highestRarity = rarity;
          break;
        }
      }

      return AchievementStats(
        total: AchievementDefinitions.totalCount,
        unlocked: unlocked.length,
        totalXp: totalXp,
        byRarity: byRarity,
        highestRarity: highestRarity,
      );
    },
    loading: () => AchievementStats.empty(),
    error: (_, __) => AchievementStats.empty(),
  );
}

/// Achievement statistics summary
class AchievementStats {
  final int total;
  final int unlocked;
  final int totalXp;
  final Map<AchievementRarity, int> byRarity;
  final AchievementRarity? highestRarity;

  const AchievementStats({
    required this.total,
    required this.unlocked,
    required this.totalXp,
    required this.byRarity,
    this.highestRarity,
  });

  factory AchievementStats.empty() => const AchievementStats(
        total: 0,
        unlocked: 0,
        totalXp: 0,
        byRarity: {},
      );

  double get completionPercent => total > 0 ? unlocked / total : 0.0;
  int get completionPercentInt => (completionPercent * 100).round();
  int get remaining => total - unlocked;
}
