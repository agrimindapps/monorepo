import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/enums.dart';
import '../game/game_2048.dart';
import '../providers/game_2048_notifier.dart';
import '../widgets/game_controls_widget.dart';
import '../widgets/game_over_dialog.dart';

/// Main page for 2048 game
class Game2048Page extends ConsumerStatefulWidget {
  const Game2048Page({super.key});

  @override
  ConsumerState<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends ConsumerState<Game2048Page> {
  Game2048? _game;

  @override
  void initState() {
    super.initState();
    // Initialize game after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(game2048Provider.notifier).initializeGame();
    });
  }

  void _initGame(int gridSize) {
    _game = Game2048(
      gridSize: gridSize,
      onScoreChanged: (score) {
        // Add score to current score
        final currentScore = ref.read(game2048Provider).score;
        ref.read(game2048Provider.notifier).updateScore(currentScore + score);
      },
      onGameOver: () {
        ref.read(game2048Provider.notifier).gameOver();
      },
      onWin: () {
        ref.read(game2048Provider.notifier).win();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(game2048Provider);
    final notifier = ref.read(game2048Provider.notifier);

    // Initialize or re-initialize game if board size changes
    if (_game == null || _game!.gridSize != gameState.boardSize.size) {
      _initGame(gameState.boardSize.size);
    }

    // Show game over dialog when game ends
    if (gameState.status == GameStatus.won ||
        gameState.status == GameStatus.gameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog(context);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: true,
        backgroundColor: const Color(0xFF8F7A66),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<BoardSize>(
            icon: const Icon(Icons.grid_4x4),
            tooltip: 'Tamanho do tabuleiro',
            onSelected: (size) {
              notifier.changeBoardSize(size);
              // Game will be re-initialized in build
            },
            itemBuilder: (context) => BoardSize.values.map((size) {
              return PopupMenuItem(
                value: size,
                child: Row(
                  children: [
                    if (gameState.boardSize == size)
                      const Icon(Icons.check, size: 18),
                    if (gameState.boardSize == size) const SizedBox(width: 8),
                    Text(size.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFAF8EF),
      body: SafeArea(
        child: Column(
          children: [
            // Controls (score, moves, restart)
            GameControlsWidget(
              score: gameState.score,
              bestScore: gameState.bestScore,
              moves: gameState.moves,
              onRestart: () => _showRestartConfirmation(context),
            ),

            const SizedBox(height: 24),

            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Deslize para combinar números e alcançar 2048!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Game grid with Flame
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: GameWidget(
                      game: _game!,
                      key: ValueKey(gameState.boardSize), // Force rebuild on resize
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Shows game over/win dialog
  void _showGameOverDialog(BuildContext context) {
    final gameState = ref.read(game2048Provider);
    final notifier = ref.read(game2048Provider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        hasWon: gameState.status == GameStatus.won,
        score: gameState.score,
        moves: gameState.moves,
        duration: gameState.gameDuration,
        isNewHighScore: notifier.isNewHighScore,
        onRestart: () {
          notifier.restart();
          _game?.restart();
        },
        onContinue: gameState.status == GameStatus.won
            ? () => notifier.continueAfterWin()
            : null,
      ),
    );
  }

  /// Shows restart confirmation dialog
  void _showRestartConfirmation(BuildContext context) {
    final notifier = ref.read(game2048Provider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar Jogo'),
        content: const Text(
          'Tem certeza que deseja reiniciar? Você perderá o progresso atual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.restart();
              _game?.restart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}
