import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state_entity.dart';
import 'lives_display_widget.dart';
import 'countdown_timer_widget.dart';
import 'speed_run_progress_widget.dart';

class GameStatsWidget extends StatelessWidget {
  final GameStateEntity gameState;

  const GameStatsWidget({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Mode indicator (if not classic)
          if (gameState.gameMode != SudokuGameMode.classic) ...[
            _buildModeIndicator(),
            const SizedBox(height: 12),
          ],

          // Main stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildStats(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getModeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getModeColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            gameState.gameMode.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            gameState.gameMode.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getModeColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor() {
    switch (gameState.gameMode) {
      case SudokuGameMode.classic:
        return Colors.blue;
      case SudokuGameMode.timeAttack:
        return Colors.orange;
      case SudokuGameMode.hardcore:
        return Colors.red;
      case SudokuGameMode.zen:
        return Colors.teal;
      case SudokuGameMode.speedRun:
        return Colors.purple;
    }
  }

  List<Widget> _buildStats() {
    final stats = <Widget>[];

    // Time stat - different based on mode
    if (gameState.gameMode == SudokuGameMode.timeAttack &&
        gameState.remainingTime != null) {
      // Show countdown for TimeAttack
      stats.add(
        CountdownStatWidget(remainingSeconds: gameState.remainingTime!),
      );
    } else if (gameState.gameMode != SudokuGameMode.zen) {
      // Show elapsed time (but not in Zen mode)
      stats.add(
        _buildStat(
          icon: Icons.timer_outlined,
          label: 'Tempo',
          value: gameState.formattedTime,
        ),
      );
    }

    // Difficulty
    stats.add(
      _buildStat(
        icon: Icons.sports_score,
        label: 'Dificuldade',
        value: gameState.difficulty.label,
      ),
    );

    // Errors stat - different based on mode
    if (gameState.gameMode == SudokuGameMode.hardcore) {
      // Show lives for Hardcore
      stats.add(
        LivesStatWidget(
          lives: gameState.livesRemaining,
          maxLives: gameState.gameMode.maxMistakes ?? 3,
        ),
      );
    } else if (gameState.gameMode != SudokuGameMode.zen) {
      // Show mistakes count (but not in Zen mode)
      stats.add(
        _buildStat(
          icon: Icons.error_outline,
          label: 'Erros',
          value: gameState.mistakes.toString(),
        ),
      );
    }

    // SpeedRun progress
    if (gameState.gameMode == SudokuGameMode.speedRun) {
      stats.add(
        SpeedRunStatWidget(
          completed: gameState.speedRunPuzzlesCompleted,
          total: gameState.gameMode.speedRunPuzzleCount,
          totalTime: gameState.speedRunTotalTime,
        ),
      );
    } else {
      // Progress for non-SpeedRun modes
      stats.add(
        _buildStat(
          icon: Icons.trending_up,
          label: 'Progresso',
          value: '${(gameState.progress * 100).toInt()}%',
        ),
      );
    }

    return stats;
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
