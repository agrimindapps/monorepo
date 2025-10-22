import 'package:flutter/material.dart';

import '../../domain/entities/game_state_entity.dart';

/// Dialog shown when word is completed or game ends
class VictoryDialog extends StatelessWidget {
  final GameStateEntity gameState;
  final VoidCallback onPlayAgain;
  final VoidCallback onMainMenu;

  const VictoryDialog({
    super.key,
    required this.gameState,
    required this.onPlayAgain,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isVictory = gameState.status == GameStatus.wordCompleted;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVictory ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 64,
              color: isVictory ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isVictory ? 'Parabéns!' : 'Fim de Jogo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isVictory ? Colors.green : Colors.red,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isVictory
                  ? 'Você completou a palavra!'
                  : 'Tente novamente!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _StatRow(
              label: 'Palavra',
              value: gameState.currentWord.word,
            ),
            _StatRow(
              label: 'Pontuação',
              value: '${gameState.score} pontos',
            ),
            _StatRow(
              label: 'Palavras Completas',
              value: '${gameState.wordsCompleted}',
            ),
            _StatRow(
              label: 'Dificuldade',
              value: gameState.difficulty.label,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: onMainMenu,
                  icon: const Icon(Icons.home),
                  label: const Text('Menu'),
                ),
                ElevatedButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Jogar Novamente'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
