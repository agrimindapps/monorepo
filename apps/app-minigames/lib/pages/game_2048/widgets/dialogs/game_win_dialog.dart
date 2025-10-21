// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/utils/format_utils.dart';

/// Dialog exibido quando o jogador vence o jogo (alcança 2048)
class GameWinDialog extends StatelessWidget {
  final int currentScore;
  final int moveCount;
  final Duration gameDuration;
  final VoidCallback onNewGame;
  final VoidCallback onContinue;

  const GameWinDialog({
    super.key,
    required this.currentScore,
    required this.moveCount,
    required this.gameDuration,
    required this.onNewGame,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🎉 Parabéns!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Você alcançou 2048!'),
          const SizedBox(height: 8),
          Text('Pontuação: $currentScore'),
          const SizedBox(height: 4),
          Text('Movimentos: $moveCount'),
          const SizedBox(height: 4),
          Text('Tempo: ${FormatUtils.formatDuration(gameDuration)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onNewGame,
          child: const Text('Novo Jogo'),
        ),
        TextButton(
          onPressed: onContinue,
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
