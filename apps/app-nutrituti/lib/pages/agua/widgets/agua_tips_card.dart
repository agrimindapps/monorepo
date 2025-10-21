// Flutter imports:
import 'package:flutter/material.dart';

class AguaTipsCard extends StatelessWidget {
  final String tip;

  const AguaTipsCard({
    super.key,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Dica do Dia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tip,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
