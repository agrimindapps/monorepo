import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/shared/game_over_dialog.dart' as shared;
import '../../domain/entities/enums.dart';
import '../providers/campo_minado_game_notifier.dart';

/// Adapter for Campo Minado game over dialog
class CampoMinadoGameOverDialogAdapter extends ConsumerWidget {
  final GameStatus status;

  const CampoMinadoGameOverDialogAdapter({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(campoMinadoGameProvider);
    final newAchievements = ref
        .read(campoMinadoGameProvider.notifier)
        .newlyUnlockedAchievements;

    final isVictory = status == GameStatus.won;

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
        icon: '⏱️',
        label: 'Tempo',
        value: gameState.formattedTime,
      ),
      shared.GameStat(
        icon: '⭐',
        label: 'Dificuldade',
        value: gameState.difficulty.label,
      ),
    ];

    return shared.GameOverDialog(
      isVictory: isVictory,
      gameTitle: 'Campo Minado',
      score: gameState.score,
      isNewHighScore: false, // TODO: Implement high score tracking
      stats: stats,
      newAchievements: achievements,
      onPlayAgain: () => ref.read(campoMinadoGameProvider.notifier).newGame(),
      onExit: () => context.go('/'),
      victoryColor: Colors.amber,
      defeatColor: Colors.red,
    );
  }
}
