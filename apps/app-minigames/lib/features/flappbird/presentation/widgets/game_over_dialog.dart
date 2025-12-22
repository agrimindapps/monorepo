// Flutter imports:
import 'package:flutter/material.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/entities/enums.dart';

/// Game over dialog overlay
class GameOverDialog extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onRestart;
  final VoidCallback? onShowAchievements;
  final VoidCallback? onShowStats;
  final VoidCallback? onChangeMode;
  final List<FlappyAchievementDefinition> newAchievements;
  final FlappyGameMode gameMode;
  final FlappyDifficulty difficulty;
  final bool survived; // For Time Attack

  const GameOverDialog({
    super.key,
    required this.score,
    required this.highScore,
    required this.onRestart,
    this.onShowAchievements,
    this.onShowStats,
    this.onChangeMode,
    this.newAchievements = const [],
    this.gameMode = FlappyGameMode.classic,
    this.difficulty = FlappyDifficulty.medium,
    this.survived = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score > 0 && score == highScore;
    final isTimeAttack = gameMode == FlappyGameMode.timeAttack;
    final title = isTimeAttack && survived ? 'Você Sobreviveu!' : 'Game Over';
    final titleColor = isTimeAttack && survived ? Colors.green : Colors.red;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: titleColor.shade700,
                ),
              ),

              const SizedBox(height: 8),

              // Game mode info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${gameMode.emoji} ${gameMode.label} - ${_getDifficultyName(difficulty)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Score
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // High score
              if (isNewHighScore)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'New High Score!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                )
              else if (highScore > 0)
                Text(
                  'Best: $highScore',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade700,
                  ),
                ),

              // New achievements
              if (newAchievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🏆', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            'Novas Conquistas!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: newAchievements.map((achievement) {
                          return Chip(
                            avatar: Text(achievement.emoji),
                            label: Text(
                              achievement.title,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: achievement.rarity.color.withValues(alpha: 0.2),
                            side: BorderSide(color: achievement.rarity.color),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Change mode button
                  if (onChangeMode != null)
                    IconButton(
                      onPressed: onChangeMode,
                      icon: const Icon(Icons.settings),
                      tooltip: 'Mudar Modo',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                    ),

                  // Achievements button
                  if (onShowAchievements != null)
                    IconButton(
                      onPressed: onShowAchievements,
                      icon: const Icon(Icons.emoji_events),
                      tooltip: 'Conquistas',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.amber[100],
                      ),
                    ),

                  // Stats button
                  if (onShowStats != null)
                    IconButton(
                      onPressed: onShowStats,
                      icon: const Icon(Icons.bar_chart),
                      tooltip: 'Estatísticas',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Restart button
              ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(
                    fontSize: 24,
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

  String _getDifficultyName(FlappyDifficulty difficulty) {
    switch (difficulty) {
      case FlappyDifficulty.easy:
        return 'Fácil';
      case FlappyDifficulty.medium:
        return 'Médio';
      case FlappyDifficulty.hard:
        return 'Difícil';
    }
  }
}
