// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/utils/format_utils.dart';

/// Dialog exibido quando o jogo termina (sem mais movimentos possíveis)
class GameOverDialog extends StatelessWidget {
  final int finalScore;
  final int highScore;
  final int moveCount;
  final Duration gameDuration;
  final VoidCallback onPlayAgain;

  const GameOverDialog({
    super.key,
    required this.finalScore,
    required this.highScore,
    required this.moveCount,
    required this.gameDuration,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Over!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Não há mais movimentos possíveis.'),
          const SizedBox(height: 8),
          Text('Pontuação Final: $finalScore'),
          Text('Melhor Pontuação: $highScore'),
          const SizedBox(height: 4),
          Text('Movimentos: $moveCount'),
          const SizedBox(height: 4),
          Text('Tempo: ${FormatUtils.formatDuration(gameDuration)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onPlayAgain,
          child: const Text('Jogar Novamente'),
        ),
      ],
    );
  }
}
