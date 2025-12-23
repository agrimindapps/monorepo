import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/shared/game_achievements_dialog.dart' as dialog;
import '../../domain/entities/achievement.dart';
import '../providers/achievement_provider.dart';

/// Adapter for Snake achievements
class SnakeAchievementsDialogAdapter extends ConsumerWidget {
  const SnakeAchievementsDialogAdapter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final statsData = ref.watch(achievementStatsProvider);

    final stats = dialog.AchievementStats(
      unlocked: statsData.unlocked,
      total: statsData.total,
      totalXp: statsData.totalXp,
      highestRarity: statsData.highestRarity?.label,
      highestRarityColor: statsData.highestRarity?.color,
      remaining: statsData.remaining,
      completionPercent: statsData.completionPercent,
    );

    final snapshot = achievementsAsync.when(
      data: (achievements) =>
          AsyncSnapshot<List<dialog.AchievementItem>>.withData(
            ConnectionState.done,
            _convertAchievements(
              achievements
                  .map((a) => SnakeAchievementWithDefinition.fromAchievement(a))
                  .toList(),
            ),
          ),
      loading: () =>
          const AsyncSnapshot<List<dialog.AchievementItem>>.waiting(),
      error: (error, stack) =>
          AsyncSnapshot<List<dialog.AchievementItem>>.withError(
            ConnectionState.done,
            error,
            stack,
          ),
    );

    return dialog.GameAchievementsDialog(
      gameTitle: 'Snake',
      stats: stats,
      achievementsSnapshot: snapshot,
      primaryColor: Colors.greenAccent,
      secondaryColor: Colors.blueAccent,
    );
  }

  List<dialog.AchievementItem> _convertAchievements(
    List<SnakeAchievementWithDefinition> achievements,
  ) {
    return achievements.map((achievement) {
      return dialog.AchievementItem(
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
