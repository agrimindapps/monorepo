// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Domain imports:
import '../../domain/entities/snake_statistics.dart';
import '../../domain/entities/player_level.dart';

/// Dialog showing player statistics
class StatisticsDialog extends StatelessWidget {
  final SnakeStatistics statistics;
  final PlayerLevel playerLevel;
  final VoidCallback? onShare;

  const StatisticsDialog({
    super.key,
    required this.statistics,
    required this.playerLevel,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📊 ESTATÍSTICAS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Player Level Section
                  _buildLevelSection(),
                  
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  
                  // Game Stats
                  _buildStatRow('🎮 Partidas Jogadas', '${statistics.totalGamesPlayed}'),
                  _buildStatRow('🏆 Maior Score', '${statistics.highestScore}'),
                  _buildStatRow('📏 Maior Cobra', '${statistics.longestSnake}'),
                  _buildStatRow('🍎 Comida Total', '${statistics.totalFoodEaten}'),
                  _buildStatRow('⚡ Power-ups', '${statistics.totalPowerUpsCollected}'),
                  _buildStatRow('⏱️ Tempo Jogado', statistics.formattedPlayTime),
                  
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  
                  // Win Stats
                  const Text(
                    'Vitórias por Dificuldade',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDifficultyWins('Fácil', statistics.gamesWonEasy, Colors.green),
                      _buildDifficultyWins('Médio', statistics.gamesWonMedium, Colors.orange),
                      _buildDifficultyWins('Difícil', statistics.gamesWonHard, Colors.red),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Streak Stats
                  _buildStatRow('🔥 Sequência Atual', '${statistics.currentWinStreak}'),
                  _buildStatRow('⭐ Melhor Sequência', '${statistics.bestWinStreak}'),
                  
                  const SizedBox(height: 20),
                  
                  // Share Button
                  if (onShare != null)
                    ElevatedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share),
                      label: const Text('COMPARTILHAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent.withValues(alpha: 0.2),
            Colors.blueAccent.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.greenAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Level ${playerLevel.currentLevel}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  playerLevel.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // XP Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${playerLevel.xpInCurrentLevel} XP',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    playerLevel.isMaxLevel 
                        ? 'MAX' 
                        : '${playerLevel.xpNeededForLevelUp} XP',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: playerLevel.levelProgressPercent,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Total: ${playerLevel.totalXp} XP',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyWins(String label, int wins, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '$wins',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
