import 'package:flutter/material.dart';

/// Widget displaying game controls (score, moves, restart button)
class GameControlsWidget extends StatelessWidget {
  final int score;
  final int bestScore;
  final int moves;
  final VoidCallback onRestart;
  final VoidCallback? onSettings;

  const GameControlsWidget({
    super.key,
    required this.score,
    required this.bestScore,
    required this.moves,
    required this.onRestart,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score and best score
          Expanded(
            child: Row(
              children: [
                _buildScoreCard('PONTOS', score, Colors.orange),
                const SizedBox(width: 12),
                _buildScoreCard('MELHOR', bestScore, Colors.amber),
                const SizedBox(width: 12),
                _buildScoreCard('JOGADAS', moves, Colors.blue),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              if (onSettings != null)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: onSettings,
                  color: Colors.grey[700],
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRestart,
                color: Colors.grey[700],
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color.darken(0.3),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.darken(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}
