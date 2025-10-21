// Flutter imports:
import 'package:flutter/material.dart';

class TipCardWidget extends StatelessWidget {
  final String tip;

  const TipCardWidget({
    super.key,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber[700], size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
