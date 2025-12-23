import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/shared/game_achievements_dialog.dart';
import '../../domain/entities/achievement.dart';
import '../providers/achievement_provider.dart';

/// Adapter for Flappy Bird achievements
class FlappyAchievementsDialogAdapter extends ConsumerWidget {
  const FlappyAchievementsDialogAdapter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(flappyAchievementsProvider);
    final statsData = ref.watch(flappyAchievementStatsProvider);

    final stats = AchievementStats(
      unlocked: statsData.unlocked,
      total: statsData.total,
      totalXp: statsData.totalXp,
      highestRarity: statsData.highestRarity?.label,
      highestRarityColor: statsData.highestRarity?.color,
      remaining: statsData.remaining,
      completionPercent: statsData.completionPercent,
    );

    final snapshot = achievementsAsync.when(
      data: (achievements) => AsyncSnapshot<List<AchievementItem>>.withData(
        ConnectionState.done,
        _convertAchievements(
          achievements
              .map((a) => FlappyAchievementWithDefinition.fromAchievement(a))
              .toList(),
        ),
      ),
      loading: () => const AsyncSnapshot<List<AchievementItem>>.waiting(),
      error: (error, stack) => AsyncSnapshot<List<AchievementItem>>.withError(
        ConnectionState.done,
        error,
        stack,
      ),
    );

    return GameAchievementsDialog(
      gameTitle: 'Flappy Bird',
      stats: stats,
      achievementsSnapshot: snapshot,
      primaryColor: Colors.amber,
      secondaryColor: Colors.orange,
    );
  }

  List<AchievementItem> _convertAchievements(
    List<FlappyAchievementWithDefinition> achievements,
  ) {
    return achievements.map((achievement) {
      return AchievementItem(
        id: achievement.definition.id,
        title: achievement.definition.title,
        description: achievement.definition.description,
        emoji: achievement.definition.emoji,
        category: achievement.definition.category.label,
        categoryEmoji: achievement.definition.category.emoji,
        rarity: achievement.definition.rarity.label,
        rarityColor: achievement.definition.rarity.color,
        xpReward: achievement.definition.rarity.xpReward,
        isUnlocked: achievement.achievement.isUnlocked,
        isSecret: achievement.definition.isSecret,
        currentProgress: achievement.achievement.currentProgress,
        target: achievement.definition.target,
      );
    }).toList();
  }
}
