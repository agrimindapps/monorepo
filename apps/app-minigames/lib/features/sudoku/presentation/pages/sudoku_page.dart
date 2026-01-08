import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/esc_keyboard_wrapper.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/achievement.dart';
import '../providers/sudoku_notifier.dart';
import '../widgets/game_controls_widget.dart';
import '../widgets/game_stats_widget.dart';
import '../widgets/number_pad_widget.dart';
import '../widgets/sudoku_grid_widget.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/achievements_dialog_adapter.dart';
import '../widgets/game_mode_dialog.dart';
import '../widgets/game_over_mode_dialog.dart';

class SudokuPage extends ConsumerStatefulWidget {
  const SudokuPage({super.key});

  @override
  ConsumerState<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends ConsumerState<SudokuPage> {
  bool _hasShownGameEndDialog = false;

  @override
  void initState() {
    super.initState();
    // Show mode selection dialog on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameModeDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(sudokuGameProvider);

    // Handle game end states
    ref.listen(sudokuGameProvider, (previous, next) {
      if (previous?.status != next.status) {
        _hasShownGameEndDialog = false;
      }

      if (!_hasShownGameEndDialog) {
        if (next.isGameWon) {
          _hasShownGameEndDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showVictoryDialog();
          });
        } else if (next.isGameLost) {
          _hasShownGameEndDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showGameOverDialog();
          });
        }
      }
    });

    return GamePageLayout(
      title: 'Sudoku',
      accentColor: const Color(0xFF673AB7),
      instructions: 'Preencha o tabuleiro 9x9!\n\n'
          '🔢 Cada linha: números 1-9\n'
          '📊 Cada coluna: números 1-9\n'
          '⬜ Cada bloco 3x3: números 1-9\n'
          '📝 Use notas para marcar possibilidades',
      maxGameWidth: 600,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events, color: Colors.white),
          tooltip: 'Conquistas',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const SudokuAchievementsDialogAdapter(),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Novo Jogo',
          onPressed: _showGameModeDialog,
        ),
        PopupMenuButton<GameDifficulty>(
          icon: const Icon(Icons.tune, color: Colors.white),
          tooltip: 'Dificuldade',
          onSelected: (difficulty) {
            ref.read(sudokuGameProvider.notifier).startNewGame(
                  difficulty,
                  gameMode: gameState.gameMode,
                );
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: GameDifficulty.easy,
              child: Text('Fácil'),
            ),
            const PopupMenuItem(
              value: GameDifficulty.medium,
              child: Text('Médio'),
            ),
            const PopupMenuItem(
              value: GameDifficulty.hard,
              child: Text('Difícil'),
            ),
          ],
        ),
      ],
      child: EscKeyboardWrapper(
        onEscPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Pausado'),
              content: const Text('Pressione ESC para continuar ou Reiniciar'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continuar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(sudokuGameProvider.notifier).restartGame();
                  },
                  child: const Text('Reiniciar'),
                ),
              ],
            ),
          );
        },
        child: Column(
          children: [
            // Game stats
            GameStatsWidget(gameState: gameState),

            const SizedBox(height: 12),

            // Sudoku grid
            Expanded(
              child: Center(
                child: SudokuGridWidget(
                  grid: gameState.grid,
                  selectedCell: gameState.selectedCell,
                  onCellTap: (row, col) {
                    ref.read(sudokuGameProvider.notifier).selectCell(row, col);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Number pad
            NumberPadWidget(
              notesMode: gameState.notesMode,
              onNumberTap: (number) {
                ref.read(sudokuGameProvider.notifier).placeNumber(number);
              },
              onClearTap: () {
                ref.read(sudokuGameProvider.notifier).clearCell();
              },
            ),

            const SizedBox(height: 8),

            // Game controls with undo/redo
            GameControlsWidget(
              notesMode: gameState.notesMode,
              canUseHint: gameState.canUseHint,
              canUndo: gameState.canUndo,
              canRedo: gameState.canRedo,
              onNotesToggle: () {
                ref.read(sudokuGameProvider.notifier).toggleNotesMode();
              },
              onHint: () {
                ref.read(sudokuGameProvider.notifier).getHint();
              },
              onRestart: () {
                _showRestartDialog();
              },
              onUndo: () {
                ref.read(sudokuGameProvider.notifier).undo();
              },
              onRedo: () {
                ref.read(sudokuGameProvider.notifier).redo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGameModeDialog() {
    final gameState = ref.read(sudokuGameProvider);
    showDialog(
      context: context,
      builder: (context) => GameModeDialog(
        initialDifficulty: gameState.difficulty,
        initialMode: gameState.gameMode,
        onStart: (difficulty, mode) {
          ref.read(sudokuGameProvider.notifier).startNewGame(
                difficulty,
                gameMode: mode,
              );
        },
      ),
    );
  }

  void _showVictoryDialog() {
    final gameState = ref.read(sudokuGameProvider);
    final gameNotifier = ref.read(sudokuGameProvider.notifier);
    final newAchievements = gameNotifier.newlyUnlockedAchievements
        .whereType<SudokuAchievementDefinition>()
        .toList();

    // For SpeedRun, show special dialog
    if (gameState.gameMode == SudokuGameMode.speedRun) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GameOverModeDialog(
          gameMode: gameState.gameMode,
          reason: GameOverReason.speedRunComplete,
          time: gameState.formattedTime,
          moves: gameState.moves,
          mistakes: gameState.mistakes,
          difficulty: gameState.difficulty,
          speedRunTotalTime: gameState.speedRunTotalTime,
          speedRunPuzzlesCompleted: gameState.speedRunPuzzlesCompleted,
          newAchievements: newAchievements,
          onPlayAgain: () {
            Navigator.pop(context);
            gameNotifier.clearNewlyUnlockedAchievements();
            _showGameModeDialog();
          },
          onChangeMode: () {
            Navigator.pop(context);
            gameNotifier.clearNewlyUnlockedAchievements();
            _showGameModeDialog();
          },
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        time: gameState.formattedTime,
        moves: gameState.moves,
        mistakes: gameState.mistakes,
        difficulty: gameState.difficulty,
        isNewRecord: gameState.isNewHighScore,
        newAchievements: newAchievements,
        onPlayAgain: () {
          Navigator.pop(context);
          gameNotifier.clearNewlyUnlockedAchievements();
          ref.read(sudokuGameProvider.notifier).restartGame();
        },
        onChangeDifficulty: (difficulty) {
          Navigator.pop(context);
          gameNotifier.clearNewlyUnlockedAchievements();
          ref.read(sudokuGameProvider.notifier).startNewGame(
                difficulty,
                gameMode: gameState.gameMode,
              );
        },
      ),
    );
  }

  void _showGameOverDialog() {
    final gameState = ref.read(sudokuGameProvider);
    final gameNotifier = ref.read(sudokuGameProvider.notifier);
    final newAchievements = gameNotifier.newlyUnlockedAchievements
        .whereType<SudokuAchievementDefinition>()
        .toList();

    // Determine reason for game over
    GameOverReason reason;
    if (gameState.isTimeUp) {
      reason = GameOverReason.timeUp;
    } else if (gameState.isOutOfLives) {
      reason = GameOverReason.outOfLives;
    } else {
      reason = GameOverReason.outOfLives; // Default
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverModeDialog(
        gameMode: gameState.gameMode,
        reason: reason,
        time: gameState.formattedTime,
        moves: gameState.moves,
        mistakes: gameState.mistakes,
        difficulty: gameState.difficulty,
        livesRemaining: gameState.livesRemaining,
        remainingTime: gameState.remainingTime,
        speedRunTotalTime: gameState.speedRunTotalTime,
        speedRunPuzzlesCompleted: gameState.speedRunPuzzlesCompleted,
        newAchievements: newAchievements,
        onPlayAgain: () {
          Navigator.pop(context);
          gameNotifier.clearNewlyUnlockedAchievements();
          ref.read(sudokuGameProvider.notifier).restartGame();
        },
        onChangeMode: () {
          Navigator.pop(context);
          gameNotifier.clearNewlyUnlockedAchievements();
          _showGameModeDialog();
        },
      ),
    );
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar Jogo'),
        content: const Text(
          'Tem certeza que deseja reiniciar? Todo o progresso será perdido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(sudokuGameProvider.notifier).restartGame();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}
