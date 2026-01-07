// Flutter imports:
import 'package:flutter/material.dart';

/// Widget to display current score and high score
class ScoreDisplayWidget extends StatelessWidget {
  final int score;
  final int highScore;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
    required this.highScore,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Current score
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),

          // High score
          if (highScore > 0)
            Text(
              'Best: $highScore',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
