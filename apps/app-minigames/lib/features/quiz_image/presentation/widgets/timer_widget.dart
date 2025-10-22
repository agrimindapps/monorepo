import 'package:flutter/material.dart';

/// Widget that displays countdown timer with progress bar
class TimerWidget extends StatelessWidget {
  final int timeLeft;
  final int totalTime;

  const TimerWidget({
    super.key,
    required this.timeLeft,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate remaining time proportion
    final progress = totalTime > 0 ? timeLeft / totalTime : 0.0;

    // Determine color based on remaining time
    final color = _getColorForProgress(progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time remaining text
        Row(
          children: [
            const Icon(Icons.timer, size: 18),
            const SizedBox(width: 5),
            Text(
              '$timeLeft s',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getColorForProgress(double progress) {
    // Red when less than 20% of time
    if (progress < 0.2) {
      return Colors.red;
    }
    // Orange when less than 50% of time
    else if (progress < 0.5) {
      return Colors.orange;
    }
    // Green for rest of time
    else {
      return Colors.green;
    }
  }
}
