// Flutter imports:
import 'package:flutter/material.dart';

class ScoreLivesDisplay extends StatelessWidget {
  final int score;
  final int lives;

  const ScoreLivesDisplay({
    super.key,
    required this.score,
    required this.lives,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatusCard(Icons.star, Colors.amber, 'Pontos', score.toString()),
        _buildStatusCard(Icons.favorite, Colors.red, 'Vidas', lives.toString()),
      ],
    );
  }

  Widget _buildStatusCard(
      IconData icon, Color color, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text('$label: $value', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
