import 'package:flame/game.dart';
import 'game_2048_high_scores_page.dart';
import 'game_2048_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/pause_menu_overlay.dart';
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

    return GamePageLayout(
      title: '2048',
      accentColor: const Color(0xFFEDC22E),
      instructions: 'Deslize para combinar números!\n\n'
          '👆 Deslize em qualquer direção\n'
          '🔢 Números iguais se combinam\n'
          '🎯 Alcance 2048 para vencer!',
      maxGameWidth: 500,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Game2048HighScoresPage()),
            );
          },
          tooltip: 'High Scores',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Game2048SettingsPage()),
            );
          },
          tooltip: 'Configurações',
        ),
        PopupMenuButton<BoardSize>(
          icon: const Icon(Icons.grid_4x4, color: Colors.white),
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
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Reiniciar',
          onPressed: () => _showRestartConfirmation(context),
        ),
      ],
      child: Column(
        children: [
          // Controls (score, moves, restart)
          GameControlsWidget(
            score: gameState.score,
            bestScore: gameState.bestScore,
            moves: gameState.moves,
            onRestart: () => _showRestartConfirmation(context),
          ),

          const SizedBox(height: 16),

          // Game grid with Flame
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Ensure we have valid constraints before rendering game
                if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFEDC22E),
                    ),
                  );
                }

                final size = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;

                return Center(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _game != null
                          ? RepaintBoundary(
                              child: GameWidget(
                                game: _game!,
                                key: ValueKey(gameState.boardSize),
                                overlayBuilderMap: {
                                  'PauseMenu': (context, game) {
                                    final typedGame = game as Game2048;
                                    return PauseMenuOverlay(
                                      onContinue: typedGame.resumeGame,
                                      onRestart: typedGame.restartFromPause,
                                      accentColor: const Color(0xFFEDC22E),
                                    );
                                  },
                                },
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFEDC22E),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Game2048HighScoresPage()),
            );
          },
          tooltip: 'High Scores',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Game2048SettingsPage()),
            );
          },
          tooltip: 'Configurações',
        ),
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
