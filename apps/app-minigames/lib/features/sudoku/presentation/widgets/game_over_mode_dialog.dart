import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/achievement.dart';

/// Dialog displayed when game ends due to mode-specific conditions
class GameOverModeDialog extends StatelessWidget {
  final SudokuGameMode gameMode;
  final GameOverReason reason;
  final String time;
  final int moves;
  final int mistakes;
  final GameDifficulty difficulty;
  final Duration? speedRunTotalTime;
  final int? speedRunPuzzlesCompleted;
  final int? livesRemaining;
  final int? remainingTime;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeMode;
  final List<SudokuAchievementDefinition> newAchievements;

  const GameOverModeDialog({
    super.key,
    required this.gameMode,
    required this.reason,
    required this.time,
    required this.moves,
    required this.mistakes,
    required this.difficulty,
    this.speedRunTotalTime,
    this.speedRunPuzzlesCompleted,
    this.livesRemaining,
    this.remainingTime,
    required this.onPlayAgain,
    required this.onChangeMode,
    this.newAchievements = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _buildTitle(),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode-specific message
            _buildModeMessage(),
            const SizedBox(height: 16),

            // Stats
            _buildStats(),

            // Achievements
            if (newAchievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAchievements(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onChangeMode,
          child: const Text('Mudar Modo'),
        ),
        ElevatedButton(
          onPressed: onPlayAgain,
          child: const Text('Tentar Novamente'),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    IconData icon;
    Color color;
    String title;

    switch (reason) {
      case GameOverReason.timeUp:
        icon = Icons.timer_off;
        color = Colors.orange;
        title = 'Tempo Esgotado!';
        break;
      case GameOverReason.outOfLives:
        icon = Icons.heart_broken;
        color = Colors.red;
        title = 'Game Over!';
        break;
      case GameOverReason.speedRunComplete:
        icon = Icons.emoji_events;
        color = Colors.amber;
        title = 'Speed Run Completo!';
        break;
      case GameOverReason.victory:
        icon = Icons.celebration;
        color = Colors.green;
        title = 'Parabéns!';
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeMessage() {
    String message;
    IconData icon;
    Color color;

    switch (reason) {
      case GameOverReason.timeUp:
        message =
            'O tempo acabou antes de você completar o puzzle. Tente novamente!';
        icon = Icons.timer;
        color = Colors.orange;
        break;
      case GameOverReason.outOfLives:
        message = 'Você cometeu erros demais e perdeu todas as vidas!';
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case GameOverReason.speedRunComplete:
        final totalMins = speedRunTotalTime?.inMinutes ?? 0;
        final totalSecs = (speedRunTotalTime?.inSeconds ?? 0) % 60;
        message =
            'Você completou ${speedRunPuzzlesCompleted ?? 5} puzzles em $totalMins:${totalSecs.toString().padLeft(2, '0')}!';
        icon = Icons.speed;
        color = Colors.purple;
        break;
      case GameOverReason.victory:
        message = 'Você completou o puzzle com sucesso!';
        icon = Icons.check_circle;
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: _darken(color)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Column(
      children: [
        _buildStatRow('Modo', '${gameMode.emoji} ${gameMode.label}'),
        _buildStatRow('Dificuldade', difficulty.label),
        _buildStatRow('Tempo Usado', time),
        _buildStatRow('Movimentos', moves.toString()),
        _buildStatRow('Erros', mistakes.toString()),

        // Mode-specific stats
        if (gameMode == SudokuGameMode.hardcore && livesRemaining != null)
          _buildStatRow('Vidas Restantes', '$livesRemaining/3'),

        if (gameMode == SudokuGameMode.timeAttack && remainingTime != null)
          _buildStatRow(
            'Tempo Restante',
            '${remainingTime! ~/ 60}:${(remainingTime! % 60).toString().padLeft(2, '0')}',
          ),

        if (gameMode == SudokuGameMode.speedRun) ...[
          _buildStatRow(
            'Puzzles Completos',
            '${speedRunPuzzlesCompleted ?? 0}/5',
          ),
          if (speedRunTotalTime != null)
            _buildStatRow(
              'Tempo Total',
              '${speedRunTotalTime!.inMinutes}:${(speedRunTotalTime!.inSeconds % 60).toString().padLeft(2, '0')}',
            ),
        ],
      ],
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
            style: TextStyle(color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Conquistas Desbloqueadas (${newAchievements.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...newAchievements.take(3).map(_buildAchievementRow),
          if (newAchievements.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '... e mais ${newAchievements.length - 3} conquista(s)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementRow(SudokuAchievementDefinition achievement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(achievement.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '+${achievement.rarity.xpReward} XP',
                  style: TextStyle(
                    fontSize: 11,
                    color: achievement.rarity.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _darken(Color color) {
    return HSLColor.fromColor(color).withLightness(0.3).toColor();
  }
}

/// Reason for game over
enum GameOverReason {
  timeUp,
  outOfLives,
  speedRunComplete,
  victory,
}
