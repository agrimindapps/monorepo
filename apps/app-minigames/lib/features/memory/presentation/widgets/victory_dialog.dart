import 'package:flutter/material.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/entities/high_score_entity.dart';

class VictoryDialog extends StatelessWidget {
  final GameStateEntity gameState;
  final HighScoreEntity? highScore;
  final bool isNewRecord;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeDifficulty;

  const VictoryDialog({
    super.key,
    required this.gameState,
    this.highScore,
    required this.isNewRecord,
    required this.onPlayAgain,
    required this.onChangeDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    final score = gameState.calculateScore();
    final elapsedTime = gameState.elapsedTime ?? Duration.zero;
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            const Text(
              'Parabéns!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você completou o jogo!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            _buildStatRow('Pontuação', '$score'),
            const SizedBox(height: 8),
            _buildStatRow('Tempo', timeString),
            const SizedBox(height: 8),
            _buildStatRow('Movimentos', '${gameState.moves}'),
            if (isNewRecord) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.new_releases, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Novo Recorde!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (highScore != null && !isNewRecord) ...[
              const SizedBox(height: 16),
              Text(
                'Melhor: ${highScore!.score} pontos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onChangeDifficulty,
                    child: const Text('Mudar Dificuldade'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPlayAgain,
                    child: const Text('Jogar Novamente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
