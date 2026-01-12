import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../widgets/shared/game_over_dialog.dart' as shared;
import '../providers/game_2048_notifier.dart';

/// Adapter for 2048 game over dialog
class Game2048GameOverDialogAdapter extends ConsumerWidget {
  final int score;
  final int highestTile;
  final bool isNewHighScore;

  const Game2048GameOverDialogAdapter({
    super.key,
    required this.score,
    required this.highestTile,
    this.isNewHighScore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build stats
    final stats = <shared.GameStat>[
      shared.GameStat(icon: '🎯', label: 'Maior Peça', value: '$highestTile'),
    ];

    return shared.GameOverDialog(
      isVictory: highestTile >= 2048,
      gameTitle: '2048',
      score: score,
      isNewHighScore: isNewHighScore,
      stats: stats,
      newAchievements: const [],
      onPlayAgain: () => ref.read(game2048Provider.notifier).restart(),
      onExit: () => rootNavigatorKey.currentContext?.go('/'),
      victoryColor: Colors.amber,
      defeatColor: Colors.orange,
    );
  }
}
