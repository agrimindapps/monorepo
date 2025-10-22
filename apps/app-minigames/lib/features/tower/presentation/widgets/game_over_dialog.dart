import 'package:flutter/material.dart';

/// Dialog shown when game is over
class GameOverDialog extends StatelessWidget {
  final int score;
  final int highScore;
  final int combo;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.highScore,
    required this.combo,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sua pontuação: $score'),
          Text('Melhor pontuação: $highScore'),
          const SizedBox(height: 10),
          Text('Maior combo: $combo'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRestart,
          child: const Text('Tentar Novamente'),
        ),
        TextButton(
          onPressed: onExit,
          child: const Text('Sair'),
        ),
      ],
    );
  }
}
