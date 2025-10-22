import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/enums.dart';
import '../providers/sudoku_notifier.dart';
import '../widgets/game_controls_widget.dart';
import '../widgets/game_stats_widget.dart';
import '../widgets/number_pad_widget.dart';
import '../widgets/sudoku_grid_widget.dart';
import '../widgets/victory_dialog.dart';

class SudokuPage extends ConsumerStatefulWidget {
  const SudokuPage({super.key});

  @override
  ConsumerState<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends ConsumerState<SudokuPage> {
  @override
  void initState() {
    super.initState();
    // Start game after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sudokuGameProvider.notifier).startNewGame(GameDifficulty.medium);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(sudokuGameProvider);

    // Show victory dialog when game is complete
    if (gameState.isGameWon) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          PopupMenuButton<GameDifficulty>(
            icon: const Icon(Icons.settings),
            onSelected: (difficulty) {
              ref.read(sudokuGameProvider.notifier).startNewGame(difficulty);
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Game stats
            GameStatsWidget(gameState: gameState),

            const SizedBox(height: 16),

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

            const SizedBox(height: 16),

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

            // Game controls
            GameControlsWidget(
              notesMode: gameState.notesMode,
              canUseHint: gameState.canUseHint,
              onNotesToggle: () {
                ref.read(sudokuGameProvider.notifier).toggleNotesMode();
              },
              onHint: () {
                ref.read(sudokuGameProvider.notifier).getHint();
              },
              onRestart: () {
                _showRestartDialog();
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showVictoryDialog() {
    final gameState = ref.read(sudokuGameProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        time: gameState.formattedTime,
        moves: gameState.moves,
        mistakes: gameState.mistakes,
        difficulty: gameState.difficulty,
        isNewRecord: gameState.isNewHighScore,
        onPlayAgain: () {
          Navigator.pop(context);
          ref.read(sudokuGameProvider.notifier).restartGame();
        },
        onChangeDifficulty: (difficulty) {
          Navigator.pop(context);
          ref.read(sudokuGameProvider.notifier).startNewGame(difficulty);
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
