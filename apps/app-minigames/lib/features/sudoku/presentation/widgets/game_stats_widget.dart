import 'package:flutter/material.dart';
import '../../domain/entities/game_state_entity.dart';

class GameStatsWidget extends StatelessWidget {
  final GameStateEntity gameState;

  const GameStatsWidget({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            icon: Icons.timer_outlined,
            label: 'Tempo',
            value: gameState.formattedTime,
          ),
          _buildStat(
            icon: Icons.sports_score,
            label: 'Dificuldade',
            value: gameState.difficulty.label,
          ),
          _buildStat(
            icon: Icons.error_outline,
            label: 'Erros',
            value: gameState.mistakes.toString(),
          ),
          _buildStat(
            icon: Icons.trending_up,
            label: 'Progresso',
            value: '${(gameState.progress * 100).toInt()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
