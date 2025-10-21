// Flutter imports:
import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int currentTime;
  final int maxTime;

  const TimerDisplay({
    super.key,
    required this.currentTime,
    required this.maxTime,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = currentTime / maxTime;

    return Column(
      children: [
        Text(
          'Tempo: $currentTime segundos',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage < 0.3 ? Colors.red : Colors.blue,
          ),
        ),
      ],
    );
  }
}
