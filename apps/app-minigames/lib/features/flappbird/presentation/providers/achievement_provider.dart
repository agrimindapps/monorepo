import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/entities/flappy_statistics.dart';
import '../../domain/entities/enums.dart';
import '../../domain/services/achievement_service.dart';
import '../../data/models/achievement_model.dart';
import 'flappbird_providers.dart';

part 'achievement_provider.g.dart';

/// Provider for Flappy Bird achievement service
@riverpod
FlappyAchievementService flappyAchievementService(Ref ref) {
  return const FlappyAchievementService();
}

/// Provider for Flappy Bird achievements state
@riverpod
class FlappyAchievementsNotifier extends _$FlappyAchievementsNotifier {
  @override
  FutureOr<List<FlappyAchievement>> build() async {
    final dataSource = ref.read(flappbirdLocalDataSourceProvider);
    final data = await dataSource.loadAchievements();

    // Initialize with all achievement definitions if empty
    if (data.achievements.isEmpty) {
      return FlappyAchievementDefinitions.all
          .map((def) => FlappyAchievement(id: def.id))
          .toList();
    }

    // Merge saved achievements with definitions (in case new achievements added)
    final savedAchievements = data.toEntities();
    final mergedAchievements = <FlappyAchievement>[];

    for (final def in FlappyAchievementDefinitions.all) {
      final saved = savedAchievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () => FlappyAchievement(id: def.id),
      );
      mergedAchievements.add(saved);
    }

    return mergedAchievements;
  }

  /// Check and update achievements based on current stats
  Future<List<FlappyAchievementDefinition>> checkAndUpdateAchievements({
    required FlappyStatistics stats,
  }) async {
    final currentAchievements = state.value ?? [];
    final service = ref.read(flappyAchievementServiceProvider);

    final updatedAchievements = service.checkAchievements(
      stats: stats,
      currentAchievements: currentAchievements,
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
  Future<List<FlappyAchievementDefinition>> processEndGame({
    required FlappyDifficulty difficulty,
    required FlappyGameMode gameMode,
    required FlappySessionStats sessionStats,
    required FlappyStatistics stats,
    required int score,
    required bool survived,
  }) async {
    final currentAchievements = state.value ?? [];
    final service = ref.read(flappyAchievementServiceProvider);

    final updatedAchievements = service.checkEndGameAchievements(
      difficulty: difficulty,
      gameMode: gameMode,
      sessionStats: sessionStats,
      stats: stats,
      score: score,
      survived: survived,
    );

    // Find newly unlocked
    final newlyUnlocked = service.getNewlyUnlocked(
      currentAchievements,
      updatedAchievements,
    );

    // Save changes
    await _saveAchievements(updatedAchievements);
    state = AsyncValue.data(updatedAchievements);

    return newlyUnlocked;
  }

  /// Get unlocked achievements
  List<FlappyAchievement> get unlockedAchievements {
    return (state.value ?? []).where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  List<FlappyAchievement> get lockedAchievements {
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
    final total = FlappyAchievementDefinitions.totalCount;
    if (total == 0) return 0.0;
    return unlockedAchievements.length / total;
  }

  /// Refresh achievements from storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dataSource = ref.read(flappbirdLocalDataSourceProvider);
      final data = await dataSource.loadAchievements();
      return data.toEntities();
    });
  }

  Future<void> _saveAchievements(
    List<FlappyAchievement> achievements,
  ) async {
    final dataSource = ref.read(flappbirdLocalDataSourceProvider);
    final data = FlappyAchievementsDataModel.fromEntities(achievements);
    await dataSource.saveAchievements(data);
  }

  bool _hasProgressChanges(
    List<FlappyAchievement> before,
    List<FlappyAchievement> after,
  ) {
    for (final afterAch in after) {
      final beforeAch = before.firstWhere(
        (a) => a.id == afterAch.id,
        orElse: () => FlappyAchievement(id: afterAch.id),
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
List<FlappyAchievement> flappyAchievementsByCategory(
  Ref ref,
  FlappyAchievementCategory category,
) {
  final achievementsAsync = ref.watch(flappyAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) =>
        achievements.where((a) => a.definition.category == category).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for achievements completion percentage
@riverpod
int flappyAchievementsCompletionPercent(Ref ref) {
  final achievementsAsync = ref.watch(flappyAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) {
      final total = FlappyAchievementDefinitions.totalCount;
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
int flappyAchievementsTotalXp(Ref ref) {
  final achievementsAsync = ref.watch(flappyAchievementsProvider);
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
int flappyUnlockedAchievementsCount(Ref ref) {
  final achievementsAsync = ref.watch(flappyAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) => achievements.where((a) => a.isUnlocked).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for recently unlocked achievements (last 7 days)
@riverpod
List<FlappyAchievement> flappyRecentlyUnlockedAchievements(Ref ref) {
  final achievementsAsync = ref.watch(flappyAchievementsProvider);
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
FlappyAchievementStats flappyAchievementStats(Ref ref) {
  final achievementsAsync = ref.watch(flappyAchievementsProvider);

  return achievementsAsync.when(
    data: (achievements) {
      final unlocked = achievements.where((a) => a.isUnlocked).toList();
      final totalXp = unlocked.fold<int>(
        0,
        (sum, a) => sum + a.definition.rarity.xpReward,
      );

      // Count by rarity
      final byRarity = <FlappyAchievementRarity, int>{};
      for (final rarity in FlappyAchievementRarity.values) {
        byRarity[rarity] =
            unlocked.where((a) => a.definition.rarity == rarity).length;
      }

      // Highest rarity unlocked
      FlappyAchievementRarity? highestRarity;
      for (final rarity in FlappyAchievementRarity.values.reversed) {
        if ((byRarity[rarity] ?? 0) > 0) {
          highestRarity = rarity;
          break;
        }
      }

      return FlappyAchievementStats(
        total: FlappyAchievementDefinitions.totalCount,
        unlocked: unlocked.length,
        totalXp: totalXp,
        byRarity: byRarity,
        highestRarity: highestRarity,
      );
    },
    loading: () => FlappyAchievementStats.empty(),
    error: (_, __) => FlappyAchievementStats.empty(),
  );
}

/// Achievement statistics summary
class FlappyAchievementStats {
  final int total;
  final int unlocked;
  final int totalXp;
  final Map<FlappyAchievementRarity, int> byRarity;
  final FlappyAchievementRarity? highestRarity;

  const FlappyAchievementStats({
    required this.total,
    required this.unlocked,
    required this.totalXp,
    required this.byRarity,
    this.highestRarity,
  });

  factory FlappyAchievementStats.empty() => const FlappyAchievementStats(
        total: 0,
        unlocked: 0,
        totalXp: 0,
        byRarity: {},
      );

  double get completionPercent => total > 0 ? unlocked / total : 0.0;
  int get completionPercentInt => (completionPercent * 100).round();
  int get remaining => total - unlocked;
}
