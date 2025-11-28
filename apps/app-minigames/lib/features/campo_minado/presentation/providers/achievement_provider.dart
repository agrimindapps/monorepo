import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/entities/campo_minado_statistics.dart';
import '../../domain/services/achievement_service.dart';
import '../../data/models/achievement_model.dart';
import 'campo_minado_game_notifier.dart';

part 'achievement_provider.g.dart';

/// Provider for Campo Minado achievement service
@riverpod
CampoMinadoAchievementService campoMinadoAchievementService(Ref ref) {
  return const CampoMinadoAchievementService();
}

/// Provider for Campo Minado achievements state
@riverpod
class CampoMinadoAchievementsNotifier extends _$CampoMinadoAchievementsNotifier {
  @override
  FutureOr<List<CampoMinadoAchievement>> build() async {
    final dataSource = ref.read(campoMinadoLocalDataSourceProvider);
    final data = await dataSource.loadAchievements();

    // Initialize with all achievement definitions if empty
    if (data.achievements.isEmpty) {
      return CampoMinadoAchievementDefinitions.all
          .map((def) => CampoMinadoAchievement(id: def.id))
          .toList();
    }

    // Merge saved achievements with definitions (in case new achievements added)
    final savedAchievements = data.toEntities();
    final mergedAchievements = <CampoMinadoAchievement>[];

    for (final def in CampoMinadoAchievementDefinitions.all) {
      final saved = savedAchievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () => CampoMinadoAchievement(id: def.id),
      );
      mergedAchievements.add(saved);
    }

    return mergedAchievements;
  }

  /// Check and update achievements based on current stats
  Future<List<CampoMinadoAchievementDefinition>> checkAndUpdateAchievements({
    required CampoMinadoStatistics stats,
  }) async {
    final currentAchievements = state.value ?? [];
    final service = ref.read(campoMinadoAchievementServiceProvider);

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
  Future<List<CampoMinadoAchievementDefinition>> processEndGame({
    required dynamic gameState, // GameState
    required GameSessionStats sessionStats,
    required CampoMinadoStatistics stats,
    required bool won,
    required int gameTimeSeconds,
  }) async {
    final currentAchievements = state.value ?? [];
    final service = ref.read(campoMinadoAchievementServiceProvider);

    final updatedAchievements = service.checkEndGameAchievements(
      gameState: gameState,
      sessionStats: sessionStats,
      stats: stats,
      currentAchievements: currentAchievements,
      won: won,
      gameTimeSeconds: gameTimeSeconds,
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
  List<CampoMinadoAchievement> get unlockedAchievements {
    return (state.value ?? []).where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  List<CampoMinadoAchievement> get lockedAchievements {
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
    final total = CampoMinadoAchievementDefinitions.totalCount;
    if (total == 0) return 0.0;
    return unlockedAchievements.length / total;
  }

  /// Refresh achievements from storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dataSource = ref.read(campoMinadoLocalDataSourceProvider);
      final data = await dataSource.loadAchievements();
      return data.toEntities();
    });
  }

  Future<void> _saveAchievements(
    List<CampoMinadoAchievement> achievements,
  ) async {
    final dataSource = ref.read(campoMinadoLocalDataSourceProvider);
    final data = CampoMinadoAchievementsDataModel.fromEntities(achievements);
    await dataSource.saveAchievements(data);
  }

  bool _hasProgressChanges(
    List<CampoMinadoAchievement> before,
    List<CampoMinadoAchievement> after,
  ) {
    for (final afterAch in after) {
      final beforeAch = before.firstWhere(
        (a) => a.id == afterAch.id,
        orElse: () => CampoMinadoAchievement(id: afterAch.id),
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
List<CampoMinadoAchievement> campoMinadoAchievementsByCategory(
  Ref ref,
  CampoMinadoAchievementCategory category,
) {
  final achievementsAsync = ref.watch(campoMinadoAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) =>
        achievements.where((a) => a.definition.category == category).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for achievements completion percentage
@riverpod
int campoMinadoAchievementsCompletionPercent(Ref ref) {
  final achievementsAsync = ref.watch(campoMinadoAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) {
      final total = CampoMinadoAchievementDefinitions.totalCount;
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
int campoMinadoAchievementsTotalXp(Ref ref) {
  final achievementsAsync = ref.watch(campoMinadoAchievementsProvider);
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
int campoMinadoUnlockedAchievementsCount(Ref ref) {
  final achievementsAsync = ref.watch(campoMinadoAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) => achievements.where((a) => a.isUnlocked).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for recently unlocked achievements (last 7 days)
@riverpod
List<CampoMinadoAchievement> campoMinadoRecentlyUnlockedAchievements(Ref ref) {
  final achievementsAsync = ref.watch(campoMinadoAchievementsProvider);
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
CampoMinadoAchievementStats campoMinadoAchievementStats(Ref ref) {
  final achievementsAsync = ref.watch(campoMinadoAchievementsProvider);

  return achievementsAsync.when(
    data: (achievements) {
      final unlocked = achievements.where((a) => a.isUnlocked).toList();
      final totalXp = unlocked.fold<int>(
        0,
        (sum, a) => sum + a.definition.rarity.xpReward,
      );

      // Count by rarity
      final byRarity = <CampoMinadoAchievementRarity, int>{};
      for (final rarity in CampoMinadoAchievementRarity.values) {
        byRarity[rarity] =
            unlocked.where((a) => a.definition.rarity == rarity).length;
      }

      // Highest rarity unlocked
      CampoMinadoAchievementRarity? highestRarity;
      for (final rarity in CampoMinadoAchievementRarity.values.reversed) {
        if ((byRarity[rarity] ?? 0) > 0) {
          highestRarity = rarity;
          break;
        }
      }

      return CampoMinadoAchievementStats(
        total: CampoMinadoAchievementDefinitions.totalCount,
        unlocked: unlocked.length,
        totalXp: totalXp,
        byRarity: byRarity,
        highestRarity: highestRarity,
      );
    },
    loading: () => CampoMinadoAchievementStats.empty(),
    error: (_, __) => CampoMinadoAchievementStats.empty(),
  );
}

/// Achievement statistics summary
class CampoMinadoAchievementStats {
  final int total;
  final int unlocked;
  final int totalXp;
  final Map<CampoMinadoAchievementRarity, int> byRarity;
  final CampoMinadoAchievementRarity? highestRarity;

  const CampoMinadoAchievementStats({
    required this.total,
    required this.unlocked,
    required this.totalXp,
    required this.byRarity,
    this.highestRarity,
  });

  factory CampoMinadoAchievementStats.empty() =>
      const CampoMinadoAchievementStats(
        total: 0,
        unlocked: 0,
        totalXp: 0,
        byRarity: {},
      );

  double get completionPercent => total > 0 ? unlocked / total : 0.0;
  int get completionPercentInt => (completionPercent * 100).round();
  int get remaining => total - unlocked;
}
