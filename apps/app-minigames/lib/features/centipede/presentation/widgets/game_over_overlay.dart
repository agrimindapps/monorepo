import 'package:flutter/material.dart';

/// Game over overlay for Centipede game
class GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final int wave;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.wave,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score > highScore && score > 0;
    
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00FF00).withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF00).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Game Over Title
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4444),
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Color(0xFFFF0000),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // New High Score Badge
              if (isNewHighScore) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'NEW HIGH SCORE!',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Stats
              _buildStatRow('Score', '$score', Colors.yellow),
              const SizedBox(height: 8),
              _buildStatRow('Wave', '$wave', Colors.cyan),
              const SizedBox(height: 8),
              _buildStatRow('High Score', '${isNewHighScore ? score : highScore}', const Color(0xFFFFD700)),
              
              const SizedBox(height: 32),
              
              // Restart Button
              ElevatedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh),
                label: const Text('PLAY AGAIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
