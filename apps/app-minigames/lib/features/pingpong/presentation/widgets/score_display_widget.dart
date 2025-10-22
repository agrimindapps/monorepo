import 'package:flutter/material.dart';

class ScoreDisplayWidget extends StatelessWidget {
  final int playerScore;
  final int aiScore;

  const ScoreDisplayWidget({
    super.key,
    required this.playerScore,
    required this.aiScore,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreText(playerScore.toString()),
          const Text(
            '-',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 32,
              fontWeight: FontWeight.w300,
            ),
          ),
          _buildScoreText(aiScore.toString()),
        ],
      ),
    );
  }

  Widget _buildScoreText(String score) {
    return Text(
      score,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.white30,
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}
