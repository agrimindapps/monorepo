import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/enums.dart';
import '../providers/game_2048_notifier.dart';
import '../widgets/game_controls_widget.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/grid_widget.dart';

/// Main page for 2048 game
class Game2048Page extends ConsumerStatefulWidget {
  const Game2048Page({super.key});

  @override
  ConsumerState<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends ConsumerState<Game2048Page> {
  @override
  void initState() {
    super.initState();
    // Initialize game after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(game2048NotifierProvider.notifier).initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(game2048NotifierProvider);
    final notifier = ref.read(game2048NotifierProvider.notifier);

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

            // Game grid with swipe detector
            Expanded(
              child: Center(
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! < -50) {
                      // Swipe up
                      notifier.move(Direction.up);
                    } else if (details.primaryVelocity! > 50) {
                      // Swipe down
                      notifier.move(Direction.down);
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < -50) {
                      // Swipe left
                      notifier.move(Direction.left);
                    } else if (details.primaryVelocity! > 50) {
                      // Swipe right
                      notifier.move(Direction.right);
                    }
                  },
                  child: GridWidget(
                    grid: gameState.grid,
                    cellSize: _calculateCellSize(
                      context,
                      gameState.boardSize.size,
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

  /// Calculates cell size based on screen width and grid size
  double _calculateCellSize(BuildContext context, int gridSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxGridWidth = screenWidth * 0.95;
    final spacing = 8.0;
    final totalSpacing = spacing * (gridSize + 1);
    final availableSpace = maxGridWidth - totalSpacing;
    final cellSize = availableSpace / gridSize;

    // Clamp between min and max sizes
    return cellSize.clamp(50.0, 80.0);
  }

  /// Shows game over/win dialog
  void _showGameOverDialog(BuildContext context) {
    final gameState = ref.read(game2048NotifierProvider);
    final notifier = ref.read(game2048NotifierProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        hasWon: gameState.status == GameStatus.won,
        score: gameState.score,
        moves: gameState.moves,
        duration: gameState.gameDuration,
        isNewHighScore: notifier.isNewHighScore,
        onRestart: () => notifier.restart(),
        onContinue: gameState.status == GameStatus.won
            ? () => notifier.continueAfterWin()
            : null,
      ),
    );
  }

  /// Shows restart confirmation dialog
  void _showRestartConfirmation(BuildContext context) {
    final notifier = ref.read(game2048NotifierProvider.notifier);

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
