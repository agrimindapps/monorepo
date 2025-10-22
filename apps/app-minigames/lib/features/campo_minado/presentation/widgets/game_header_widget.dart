import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/campo_minado_game_notifier.dart';
import '../../domain/entities/enums.dart';

/// Header widget showing game info and controls
class GameHeaderWidget extends ConsumerWidget {
  const GameHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(campoMinadoGameNotifierProvider);
    final notifier = ref.read(campoMinadoGameNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!, width: 2),
      ),
      child: Column(
        children: [
          // Timer, Restart, Mines count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer
              _InfoDisplay(
                icon: Icons.timer,
                value: gameState.formattedTime,
                color: Colors.blue,
              ),

              // Restart button
              GestureDetector(
                onTap: () => notifier.restartGame(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gameState.status.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(gameState.status),
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),

              // Remaining mines
              _InfoDisplay(
                icon: Icons.flag,
                value: gameState.remainingMines.toString().padLeft(3, '0'),
                color: Colors.red,
              ),
            ],
          ),

          // Status message
          if (gameState.status.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              gameState.status.message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: gameState.status.color,
              ),
            ),
          ],

          // Pause button (only during gameplay)
          if (gameState.isPlaying) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => notifier.togglePause(),
              icon: Icon(gameState.isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(gameState.isPaused ? 'Retomar' : 'Pausar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: gameState.isPaused ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon(GameStatus status) {
    switch (status) {
      case GameStatus.won:
        return Icons.emoji_events;
      case GameStatus.lost:
        return Icons.sentiment_dissatisfied;
      case GameStatus.playing:
        return Icons.sentiment_satisfied;
      case GameStatus.ready:
        return Icons.sentiment_neutral;
    }
  }
}

class _InfoDisplay extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoDisplay({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}
