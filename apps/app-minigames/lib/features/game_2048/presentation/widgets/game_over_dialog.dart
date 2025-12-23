import 'package:flutter/material.dart';

/// Dialog shown when game is over or won
class GameOverDialog extends StatelessWidget {
  final bool hasWon;
  final int score;
  final int moves;
  final Duration duration;
  final bool isNewHighScore;
  final VoidCallback onRestart;
  final VoidCallback? onContinue;

  const GameOverDialog({
    super.key,
    required this.hasWon,
    required this.score,
    required this.moves,
    required this.duration,
    required this.isNewHighScore,
    required this.onRestart,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasWon ? Colors.green[50] : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 48,
                color: hasWon ? Colors.green[700] : Colors.red[700],
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              hasWon ? 'Você Venceu!' : 'Fim de Jogo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: hasWon ? Colors.green[700] : Colors.red[700],
              ),
            ),

            const SizedBox(height: 8),

            // New high score badge
            if (isNewHighScore)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[600]!, Colors.amber[800]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'NOVO RECORDE!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Statistics
            _buildStatRow('Pontuação', score.toString()),
            const SizedBox(height: 12),
            _buildStatRow('Jogadas', moves.toString()),
            const SizedBox(height: 12),
            _buildStatRow('Tempo', _formatDuration(duration)),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onRestart();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reiniciar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                  ),
                ),
                if (hasWon && onContinue != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onContinue!();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
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
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }
}
