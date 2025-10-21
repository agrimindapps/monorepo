// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'controllers/sudoku_controller.dart';
import 'widgets/game_info_widget.dart';
import 'widgets/number_pad_widget.dart';
import 'widgets/sudoku_board_widget.dart';

class GameSudokuPage extends StatefulWidget {
  const GameSudokuPage({super.key});

  @override
  State<GameSudokuPage> createState() => _GameSudokuPageState();
}

class _GameSudokuPageState extends State<GameSudokuPage> {
  late SudokuController controller;

  @override
  void initState() {
    super.initState();
    controller = SudokuController();
    controller.addListener(_onGameStateChanged);
    controller.initializeGame();
  }

  @override
  void dispose() {
    try {
      controller.removeListener(_onGameStateChanged);
      controller.dispose();
    } catch (e) {
      debugPrint('Erro ao fazer dispose do controller: $e');
    } finally {
      super.dispose();
    }
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onCellTap(int row, int col) {
    if (controller.isGameOver || row < 0 || row >= 9 || col < 0 || col >= 9) {
      return;
    }

    controller.selectCell(row, col);
  }

  void _onNumberSelected(int number) {
    if (controller.isGameOver || number < 0 || number > 9) {
      return;
    }

    controller.insertNumber(number);
    if (controller.checkCompletion()) {
      controller.endGame();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showVictoryDialog();
        }
      });
    }
  }

  void _toggleNoteMode() {
    if (controller.isGameOver) {
      return;
    }

    controller.toggleNoteMode();
  }

  void _giveHint() {
    if (controller.isGameOver || controller.hintsRemaining <= 0) {
      return;
    }

    controller.giveHint();
    if (controller.checkCompletion()) {
      controller.endGame();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showVictoryDialog();
        }
      });
    }
  }

  void _restartGame() {
    controller.initializeGame();
  }

  void _showRestartConfirmationDialog() {
    if (!controller.isGameStarted || controller.isGameOver) {
      _restartGame();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Reinício'),
          content: const Text(
            'Tem certeza de que deseja reiniciar o jogo? O progresso atual será perdido.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                  _restartGame();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }

  void _updateDifficulty() {
    controller.initializeGame();
  }

  void _pauseGame() {
    controller.pauseGame();
    _showPauseDialog();
  }

  void _resumeGame() {
    controller.resumeGame();
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Jogo Pausado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tempo: ${controller.getFormattedTime()}'),
              const SizedBox(height: 10),
              Text('Pontuação: ${controller.score}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                  _resumeGame();
                }
              },
              child: const Text('Continuar'),
            ),
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                  _restartGame();
                }
              },
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Parabéns!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Você completou o puzzle!'),
              const SizedBox(height: 10),
              Text('Tempo: ${controller.getFormattedTime()}'),
              Text('Pontuação: ${controller.score}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                  _restartGame();
                }
              },
              child: const Text('Novo Jogo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header da página
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageHeaderWidget(
              title: 'Sudoku',
              subtitle: 'Complete o tabuleiro usando números de 1 a 9',
              icon: Icons.grid_on,
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.lightbulb_outline),
                  onPressed: controller.hintsRemaining > 0 ? _giveHint : null,
                ),
                IconButton(
                  icon: Icon(controller.isNoteMode ? Icons.edit_note : Icons.edit),
                  onPressed: _toggleNoteMode,
                  color: controller.isNoteMode ? Colors.amber : null,
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: controller.isGameStarted &&
                          !controller.isGameOver &&
                          !controller.isPaused
                      ? _pauseGame
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _showRestartConfirmationDialog,
                ),
              ],
            ),
          ),
          GameInfoWidget(
            gameLogic: controller.model,
            onDifficultyChanged: _updateDifficulty,
          ),
          Expanded(
            child: Center(
              child: SudokuBoardWidget(
                gameLogic: controller.model,
                onCellTap: _onCellTap,
              ),
            ),
          ),
          NumberPadWidget(
            onNumberSelected: _onNumberSelected,
            isNoteMode: controller.isNoteMode,
          ),
        ],
      ),
    );
  }
}
