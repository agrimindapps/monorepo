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
    final elapsedTime = gameState.elapsedTime ?? Duration.zero;
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.timer,
            label: 'Tempo',
            value: timeString,
          ),
          _buildStatItem(
            icon: Icons.touch_app,
            label: 'Movimentos',
            value: '${gameState.moves}',
          ),
          _buildStatItem(
            icon: Icons.star,
            label: 'Pares',
            value: '${gameState.matches}/${gameState.totalPairs}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
