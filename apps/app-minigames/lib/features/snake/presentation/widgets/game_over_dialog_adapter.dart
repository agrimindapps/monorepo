import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/shared/game_over_dialog.dart' as shared;
import '../providers/snake_game_notifier.dart';

/// Adapter for Snake game over dialog
class SnakeGameOverDialogAdapter extends ConsumerWidget {
  final int score;
  final int snakeLength;
  final bool isNewHighScore;

  const SnakeGameOverDialogAdapter({
    super.key,
    required this.score,
    required this.snakeLength,
    this.isNewHighScore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(snakeGameProvider);
    final newAchievements = ref
        .read(snakeGameProvider.notifier)
        .newlyUnlockedAchievements;

    // Convert achievements
    final achievements = newAchievements
        .map((achievement) => shared.NewAchievement(
              title: achievement.title,
              description: achievement.description,
              emoji: achievement.emoji,
              xp: achievement.rarity.xpReward,
            ))
        .toList();

    // Build stats
    final stats = <shared.GameStat>[
      shared.GameStat(
        icon: '🐍',
        label: 'Tamanho',
        value: '$snakeLength',
      ),
      shared.GameStat(
        icon: '⭐',
        label: 'Level',
        value: '${gameState.playerLevel}',
      ),
    ];

    return shared.GameOverDialog(
      isVictory: false, // Snake doesn't have victory, only game over
      gameTitle: 'Snake',
      score: score,
      isNewHighScore: isNewHighScore,
      stats: stats,
      newAchievements: achievements,
      onPlayAgain: () => ref.read(snakeGameProvider.notifier).resetGame(),
      onExit: () => context.go('/'),
      victoryColor: Colors.greenAccent,
      defeatColor: Colors.redAccent,
    );
  }
}
