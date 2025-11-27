// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

/// Enhanced game over dialog with statistics
class GameOverDialog extends StatelessWidget {
  final int score;
  final int snakeLength;
  final int xpGained;
  final int playerLevel;
  final String levelTitle;
  final bool isNewHighScore;
  final VoidCallback onPlayAgain;
  final VoidCallback? onShare;
  final VoidCallback onMenu;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.snakeLength,
    required this.xpGained,
    required this.playerLevel,
    required this.levelTitle,
    this.isNewHighScore = false,
    required this.onPlayAgain,
    this.onShare,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 350),
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isNewHighScore 
                    ? Colors.amber.withValues(alpha: 0.5)
                    : Colors.redAccent.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isNewHighScore ? Colors.amber : Colors.redAccent)
                      .withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Over Title
                Text(
                  isNewHighScore ? '🏆 NOVO RECORDE! 🏆' : 'GAME OVER',
                  style: TextStyle(
                    fontSize: isNewHighScore ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: isNewHighScore ? Colors.amber : Colors.redAccent,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 24),

                // Score
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SCORE',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isNewHighScore ? Colors.amber : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('📏', 'Tamanho', '$snakeLength'),
                    _buildStatItem('✨', 'XP', '+$xpGained'),
                  ],
                ),

                const SizedBox(height: 16),

                // Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent.withValues(alpha: 0.2),
                        Colors.blueAccent.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Level $playerLevel - $levelTitle',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  children: [
                    // Play Again Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onPlayAgain,
                        icon: const Icon(Icons.replay),
                        label: const Text('JOGAR NOVAMENTE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Share and Menu Row
                    Row(
                      children: [
                        if (onShare != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onShare,
                              icon: const Icon(Icons.share),
                              label: const Text('SHARE'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blueAccent,
                                side: const BorderSide(color: Colors.blueAccent),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        if (onShare != null) const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onMenu,
                            icon: const Icon(Icons.home),
                            label: const Text('MENU'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
