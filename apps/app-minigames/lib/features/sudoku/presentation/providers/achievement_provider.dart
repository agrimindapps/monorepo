import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/entities/sudoku_statistics.dart';
import '../../domain/entities/enums.dart';
import '../../domain/services/achievement_service.dart';
import '../../data/models/achievement_model.dart';
import 'sudoku_providers.dart';

part 'achievement_provider.g.dart';

/// Provider for Sudoku achievement service
@riverpod
SudokuAchievementService sudokuAchievementService(Ref ref) {
  return const SudokuAchievementService();
}

/// Provider for Sudoku achievements state
@riverpod
class SudokuAchievementsNotifier extends _$SudokuAchievementsNotifier {
  @override
  FutureOr<List<SudokuAchievement>> build() async {
    final dataSource = ref.read(sudokuLocalDataSourceProvider);
    final data = await dataSource.loadAchievements();

    // Initialize with all achievement definitions if empty
    if (data.achievements.isEmpty) {
      return SudokuAchievementDefinitions.all
          .map((def) => SudokuAchievement(id: def.id))
          .toList();
    }

    // Merge saved achievements with definitions (in case new achievements added)
    final savedAchievements = data.toEntities();
    final mergedAchievements = <SudokuAchievement>[];

    for (final def in SudokuAchievementDefinitions.all) {
      final saved = savedAchievements.firstWhere(
        (a) => a.id == def.id,
        orElse: () => SudokuAchievement(id: def.id),
      );
      mergedAchievements.add(saved);
    }

    return mergedAchievements;
  }

  /// Check and update achievements based on current stats
  Future<List<SudokuAchievementDefinition>> checkAndUpdateAchievements({
    required SudokuStatistics stats,
  }) async {
    final currentAchievements = state.value ?? [];
    final service = ref.read(sudokuAchievementServiceProvider);

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
  Future<List<SudokuAchievementDefinition>> processEndGame({
    required GameDifficulty difficulty,
    required SudokuSessionStats sessionStats,
    required SudokuStatistics stats,
    required bool won,
    required int gameTimeSeconds,
  }) async {
    final currentAchievements = state.value ?? [];
    final service = ref.read(sudokuAchievementServiceProvider);

    final updatedAchievements = service.checkEndGameAchievements(
      difficulty: difficulty,
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
  List<SudokuAchievement> get unlockedAchievements {
    return (state.value ?? []).where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  List<SudokuAchievement> get lockedAchievements {
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
    final total = SudokuAchievementDefinitions.totalCount;
    if (total == 0) return 0.0;
    return unlockedAchievements.length / total;
  }

  /// Refresh achievements from storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dataSource = ref.read(sudokuLocalDataSourceProvider);
      final data = await dataSource.loadAchievements();
      return data.toEntities();
    });
  }

  Future<void> _saveAchievements(
    List<SudokuAchievement> achievements,
  ) async {
    final dataSource = ref.read(sudokuLocalDataSourceProvider);
    final data = SudokuAchievementsDataModel.fromEntities(achievements);
    await dataSource.saveAchievements(data);
  }

  bool _hasProgressChanges(
    List<SudokuAchievement> before,
    List<SudokuAchievement> after,
  ) {
    for (final afterAch in after) {
      final beforeAch = before.firstWhere(
        (a) => a.id == afterAch.id,
        orElse: () => SudokuAchievement(id: afterAch.id),
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
List<SudokuAchievement> sudokuAchievementsByCategory(
  Ref ref,
  SudokuAchievementCategory category,
) {
  final achievementsAsync = ref.watch(sudokuAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) =>
        achievements.where((a) => a.definition.category == category).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for achievements completion percentage
@riverpod
int sudokuAchievementsCompletionPercent(Ref ref) {
  final achievementsAsync = ref.watch(sudokuAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) {
      final total = SudokuAchievementDefinitions.totalCount;
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
int sudokuAchievementsTotalXp(Ref ref) {
  final achievementsAsync = ref.watch(sudokuAchievementsProvider);
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
int sudokuUnlockedAchievementsCount(Ref ref) {
  final achievementsAsync = ref.watch(sudokuAchievementsProvider);
  return achievementsAsync.when(
    data: (achievements) => achievements.where((a) => a.isUnlocked).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider for recently unlocked achievements (last 7 days)
@riverpod
List<SudokuAchievement> sudokuRecentlyUnlockedAchievements(Ref ref) {
  final achievementsAsync = ref.watch(sudokuAchievementsProvider);
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
SudokuAchievementStats sudokuAchievementStats(Ref ref) {
  final achievementsAsync = ref.watch(sudokuAchievementsProvider);

  return achievementsAsync.when(
    data: (achievements) {
      final unlocked = achievements.where((a) => a.isUnlocked).toList();
      final totalXp = unlocked.fold<int>(
        0,
        (sum, a) => sum + a.definition.rarity.xpReward,
      );

      // Count by rarity
      final byRarity = <SudokuAchievementRarity, int>{};
      for (final rarity in SudokuAchievementRarity.values) {
        byRarity[rarity] =
            unlocked.where((a) => a.definition.rarity == rarity).length;
      }

      // Highest rarity unlocked
      SudokuAchievementRarity? highestRarity;
      for (final rarity in SudokuAchievementRarity.values.reversed) {
        if ((byRarity[rarity] ?? 0) > 0) {
          highestRarity = rarity;
          break;
        }
      }

      return SudokuAchievementStats(
        total: SudokuAchievementDefinitions.totalCount,
        unlocked: unlocked.length,
        totalXp: totalXp,
        byRarity: byRarity,
        highestRarity: highestRarity,
      );
    },
    loading: () => SudokuAchievementStats.empty(),
    error: (_, __) => SudokuAchievementStats.empty(),
  );
}

/// Achievement statistics summary
class SudokuAchievementStats {
  final int total;
  final int unlocked;
  final int totalXp;
  final Map<SudokuAchievementRarity, int> byRarity;
  final SudokuAchievementRarity? highestRarity;

  const SudokuAchievementStats({
    required this.total,
    required this.unlocked,
    required this.totalXp,
    required this.byRarity,
    this.highestRarity,
  });

  factory SudokuAchievementStats.empty() => const SudokuAchievementStats(
        total: 0,
        unlocked: 0,
        totalXp: 0,
        byRarity: {},
      );

  double get completionPercent => total > 0 ? unlocked / total : 0.0;
  int get completionPercentInt => (completionPercent * 100).round();
  int get remaining => total - unlocked;
}
