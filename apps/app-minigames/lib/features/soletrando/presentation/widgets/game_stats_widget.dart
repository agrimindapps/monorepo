import 'package:flutter/material.dart';

import '../../domain/entities/game_state_entity.dart';

/// Widget to display game statistics (time, score, mistakes, hints)
class GameStatsWidget extends StatelessWidget {
  final GameStateEntity gameState;

  const GameStatsWidget({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.timer,
              label: 'Tempo',
              value: _formatTime(gameState.timeRemaining),
              color: gameState.isCriticalTime ? Colors.red : Colors.blue,
            ),
            _StatItem(
              icon: Icons.star,
              label: 'Pontos',
              value: '${gameState.score}',
              color: Colors.amber,
            ),
            _StatItem(
              icon: Icons.close,
              label: 'Erros',
              value: '${gameState.mistakes}/${gameState.difficulty.mistakesAllowed}',
              color: Colors.red,
            ),
            _StatItem(
              icon: Icons.lightbulb,
              label: 'Dicas',
              value: '${gameState.hintsRemaining}',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
