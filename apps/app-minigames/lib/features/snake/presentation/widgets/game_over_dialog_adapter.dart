import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/shared/game_over_dialog.dart' as shared;
import '../providers/snake_extended_providers.dart';
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
    final playerLevelAsync = ref.watch(playerLevelProvider);

    final playerLevel = playerLevelAsync.when(
      data: (level) => level.currentLevel,
      loading: () => 1,
      error: (_, __) => 1,
    );

    // Convert achievements
    final achievements = <shared.NewAchievement>[];

    // Build stats
    final stats = <shared.GameStat>[
      shared.GameStat(icon: '🐍', label: 'Tamanho', value: '$snakeLength'),
      shared.GameStat(icon: '⭐', label: 'Level', value: '$playerLevel'),
    ];

    return shared.GameOverDialog(
      isVictory: false, // Snake doesn't have victory, only game over
      gameTitle: 'Snake',
      score: score,
      isNewHighScore: isNewHighScore,
      stats: stats,
      newAchievements: achievements,
      onPlayAgain: () => ref.read(snakeGameProvider.notifier).restartGame(),
      onExit: () => context.go('/'),
      victoryColor: Colors.greenAccent,
      defeatColor: Colors.redAccent,
    );
  }
}
