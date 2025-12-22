import 'package:flutter/material.dart';

/// Generic Game Over Dialog that can be used by any game
/// 
/// Provides a flexible, reusable game over screen with customizable content.
class GameOverDialog extends StatelessWidget {
  final bool isVictory;
  final String gameTitle;
  final int score;
  final bool isNewHighScore;
  final List<GameStat> stats;
  final List<NewAchievement> newAchievements;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;
  final Color victoryColor;
  final Color defeatColor;
  final Widget? customHeader;
  final Widget? customContent;

  const GameOverDialog({
    super.key,
    required this.isVictory,
    required this.gameTitle,
    required this.score,
    this.isNewHighScore = false,
    this.stats = const [],
    this.newAchievements = const [],
    required this.onPlayAgain,
    required this.onExit,
    this.victoryColor = Colors.amber,
    this.defeatColor = Colors.red,
    this.customHeader,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isVictory ? victoryColor : defeatColor)
                .withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isVictory ? victoryColor : defeatColor)
                  .withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom header or default
                customHeader ?? _buildDefaultHeader(),
                
                const SizedBox(height: 24),
                
                // Score section
                _buildScoreSection(),
                
                const SizedBox(height: 20),
                
                // Stats
                if (stats.isNotEmpty) ...[
                  _buildStatsSection(),
                  const SizedBox(height: 20),
                ],
                
                // New Achievements
                if (newAchievements.isNotEmpty) ...[
                  _buildAchievementsSection(),
                  const SizedBox(height: 20),
                ],
                
                // Custom content
                if (customContent != null) ...[
                  customContent!,
                  const SizedBox(height: 20),
                ],
                
                // Action buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (isVictory ? victoryColor : defeatColor)
                    .withValues(alpha: 0.3),
                (isVictory ? victoryColor : defeatColor)
                    .withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Icon(
            isVictory ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: isVictory ? victoryColor : defeatColor,
            size: 48,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Title
        Text(
          isVictory ? 'VITÓRIA!' : 'GAME OVER',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isVictory ? victoryColor : defeatColor,
            letterSpacing: 2,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Message
        Text(
          isVictory 
              ? 'Parabéns! Você venceu!' 
              : 'Tente novamente!',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNewHighScore 
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isNewHighScore ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isNewHighScore) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    'NOVO RECORDE!',
                    style: TextStyle(
                      color: Colors.amber[200],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          const Text(
            'PONTUAÇÃO',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isNewHighScore ? Colors.amber : Colors.white,
              shadows: [
                Shadow(
                  color: (isNewHighScore ? Colors.amber : Colors.white)
                      .withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        Text(
          'ESTATÍSTICAS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 2,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: stats.map((stat) => _buildStatItem(stat)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatItem(GameStat stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            stat.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            stat.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'NOVAS CONQUISTAS!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[200],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...newAchievements.map((achievement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(achievement.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            achievement.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${achievement.xp} XP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[300],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Play Again
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPlayAgain();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isVictory ? victoryColor : Colors.blue,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Jogar Novamente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Exit
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onExit();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sair',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

/// Stat item for game over dialog
class GameStat {
  final String icon;
  final String label;
  final String value;

  const GameStat({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// New achievement data
class NewAchievement {
  final String title;
  final String description;
  final String emoji;
  final int xp;

  const NewAchievement({
    required this.title,
    required this.description,
    required this.emoji,
    required this.xp,
  });
}
