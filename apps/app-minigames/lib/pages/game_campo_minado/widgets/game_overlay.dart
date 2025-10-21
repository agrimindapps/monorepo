// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_constants.dart' as constants;
import '../providers/game_state_provider.dart';

/// Overlay widget that displays game information and controls
class GameOverlay extends StatelessWidget {
  const GameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.all(constants.Layout.headerPadding),
          decoration: BoxDecoration(
            color: constants.GameColors.background,
            borderRadius: BorderRadius.circular(constants.Layout.cellBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTopRow(context, gameProvider),
              const SizedBox(height: constants.Layout.elementSpacing),
              _buildGameStatus(context, gameProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopRow(BuildContext context, GameStateProvider gameProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMineCounter(gameProvider),
        _buildDifficultySelector(context, gameProvider),
        _buildTimer(gameProvider),
      ],
    );
  }

  Widget _buildMineCounter(GameStateProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: constants.GameColors.cellHidden,
        borderRadius: BorderRadius.circular(constants.Layout.cellBorderRadius),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.flag,
            color: constants.GameColors.cellFlag,
            size: constants.GameSizes.iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            gameProvider.remainingMines.toString().padLeft(3, '0'),
            style: const TextStyle(
              fontSize: constants.GameSizes.headerFontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(GameStateProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: constants.GameColors.cellHidden,
        borderRadius: BorderRadius.circular(constants.Layout.cellBorderRadius),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Colors.blue,
            size: constants.GameSizes.iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            gameProvider.formattedTime,
            style: const TextStyle(
              fontSize: constants.GameSizes.headerFontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context, GameStateProvider gameProvider) {
    return PopupMenuButton<GameDifficulty>(
      initialValue: gameProvider.difficulty,
      onSelected: (GameDifficulty difficulty) {
        gameProvider.changeDifficulty(difficulty);
      },
      itemBuilder: (BuildContext context) {
        return GameDifficulty.values.map((GameDifficulty difficulty) {
          return PopupMenuItem<GameDifficulty>(
            value: difficulty,
            child: Row(
              children: [
                Icon(
                  _getDifficultyIcon(difficulty),
                  size: constants.GameSizes.iconSize,
                  color: _getDifficultyColor(difficulty),
                ),
                const SizedBox(width: 8),
                Text(difficulty.label),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: constants.GameColors.cellHidden,
          borderRadius: BorderRadius.circular(constants.Layout.cellBorderRadius),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getDifficultyIcon(gameProvider.difficulty),
              size: constants.GameSizes.iconSize,
              color: _getDifficultyColor(gameProvider.difficulty),
            ),
            const SizedBox(width: 4),
            Text(
              gameProvider.difficulty.label,
              style: const TextStyle(
                fontSize: constants.GameSizes.buttonFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStatus(BuildContext context, GameStateProvider gameProvider) {
    if (gameProvider.gameState.isGameOver) {
      return _buildGameOverStatus(context, gameProvider);
    }
    
    if (gameProvider.gameState.isPaused) {
      return _buildPausedStatus(context, gameProvider);
    }
    
    return _buildGameControls(context, gameProvider);
  }

  Widget _buildGameOverStatus(BuildContext context, GameStateProvider gameProvider) {
    final isWon = gameProvider.gameState.gameState == GameState.won;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWon ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(constants.Layout.cellBorderRadius),
        border: Border.all(
          color: isWon ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: constants.GameSizes.largeIconSize,
            color: isWon ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          Text(
            isWon ? 'Congratulations!' : 'Game Over',
            style: TextStyle(
              fontSize: constants.GameSizes.headerFontSize,
              fontWeight: FontWeight.bold,
              color: isWon ? Colors.green : Colors.red,
            ),
          ),
          if (isWon) ...[
            const SizedBox(height: 4),
            Text(
              'Time: ${gameProvider.formattedTime}',
              style: const TextStyle(
                fontSize: constants.GameSizes.buttonFontSize,
                color: Colors.grey,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => gameProvider.restartGame(),
            icon: const Icon(Icons.refresh),
            label: const Text('Play Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isWon ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPausedStatus(BuildContext context, GameStateProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(constants.Layout.cellBorderRadius),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.pause_circle,
            size: constants.GameSizes.largeIconSize,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          const Text(
            'Game Paused',
            style: TextStyle(
              fontSize: constants.GameSizes.headerFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => gameProvider.togglePause(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameControls(BuildContext context, GameStateProvider gameProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => gameProvider.restartGame(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Restart Game',
          iconSize: constants.GameSizes.iconSize,
        ),
        IconButton(
          onPressed: () => gameProvider.togglePause(),
          icon: Icon(gameProvider.gameState.isPaused ? Icons.play_arrow : Icons.pause),
          tooltip: gameProvider.gameState.isPaused ? 'Resume' : 'Pause',
          iconSize: constants.GameSizes.iconSize,
        ),
        IconButton(
          onPressed: () => _showStatistics(context, gameProvider),
          icon: const Icon(Icons.bar_chart),
          tooltip: 'Statistics',
          iconSize: constants.GameSizes.iconSize,
        ),
      ],
    );
  }

  IconData _getDifficultyIcon(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return Icons.sentiment_satisfied;
      case GameDifficulty.intermediate:
        return Icons.sentiment_neutral;
      case GameDifficulty.expert:
        return Icons.sentiment_very_dissatisfied;
      case GameDifficulty.custom:
        return Icons.settings;
    }
  }

  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return Colors.green;
      case GameDifficulty.intermediate:
        return Colors.orange;
      case GameDifficulty.expert:
        return Colors.red;
      case GameDifficulty.custom:
        return Colors.purple;
    }
  }

  void _showStatistics(BuildContext context, GameStateProvider gameProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Games Played: ${gameProvider.totalGames}'),
              Text('Games Won: ${gameProvider.totalWins}'),
              Text('Win Rate: ${(gameProvider.winRate * 100).toStringAsFixed(1)}%'),
              Text('Current Streak: ${gameProvider.currentStreak}'),
              Text('Best Streak: ${gameProvider.bestStreak}'),
              Text('Best Time: ${gameProvider.formattedBestTime}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
