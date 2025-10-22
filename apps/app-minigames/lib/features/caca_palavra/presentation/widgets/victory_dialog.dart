import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';

/// Dialog shown when game is completed
class VictoryDialog extends StatelessWidget {
  final GameDifficulty difficulty;
  final int wordsFound;
  final int? completionTime;
  final int? bestTime;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const VictoryDialog({
    super.key,
    required this.difficulty,
    required this.wordsFound,
    this.completionTime,
    this.bestTime,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final isNewRecord = bestTime != null &&
        completionTime != null &&
        (bestTime == 0 || completionTime! < bestTime!);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Column(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber.shade600,
            size: 64,
          ),
          const SizedBox(height: 8),
          const Text(
            'Parabéns!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Você encontrou todas as $wordsFound palavras!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.signal_cellular_alt,
            label: 'Dificuldade',
            value: difficulty.label,
          ),
          if (completionTime != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.timer,
              label: 'Tempo',
              value: _formatTime(completionTime!),
            ),
          ],
          if (bestTime != null && bestTime! > 0) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.star,
              label: 'Melhor tempo',
              value: _formatTime(bestTime!),
              isHighlighted: isNewRecord,
            ),
          ],
          if (isNewRecord) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.new_releases, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Novo recorde!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onExit,
          child: const Text('Sair'),
        ),
        ElevatedButton.icon(
          onPressed: onPlayAgain,
          icon: const Icon(Icons.refresh),
          label: const Text('Jogar Novamente'),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.amber.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlighted ? Colors.amber.shade700 : Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.amber.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }
}
