import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tictactoe_game_notifier.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_controls_widget.dart';
import '../widgets/game_stats_widget.dart';

/// Main page for TicTacToe game
/// Uses Riverpod for state management
class TicTacToePage extends ConsumerWidget {
  const TicTacToePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(ticTacToeGameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo da Velha'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStatsDialog(context, ref),
            tooltip: 'Ver Estatísticas',
          ),
        ],
      ),
      body: gameState.when(
        data: (state) => SafeArea(
          child: Column(
            children: [
              // Game status and controls
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GameControlsWidget(
                  gameState: state,
                  onGameModeChanged: (mode) {
                    ref
                        .read(ticTacToeGameProvider.notifier)
                        .changeGameMode(mode);
                  },
                  onDifficultyChanged: (difficulty) {
                    ref
                        .read(ticTacToeGameProvider.notifier)
                        .changeDifficulty(difficulty);
                  },
                  onRestart: () {
                    ref
                        .read(ticTacToeGameProvider.notifier)
                        .restartGame();
                  },
                ),
              ),

              // Current player indicator
              if (state.isInProgress)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Vez de: ${state.currentPlayer.symbol}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: state.currentPlayer.color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

              // Game result message
              if (!state.isInProgress)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        state.result.message,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(ticTacToeGameProvider.notifier)
                              .restartGame();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Jogar Novamente'),
                      ),
                    ],
                  ),
                ),

              // Game board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GameBoardWidget(
                        gameState: state,
                        onCellTapped: (row, col) {
                          ref
                              .read(ticTacToeGameProvider.notifier)
                              .makeMove(row, col);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(ticTacToeGameProvider);
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estatísticas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              GameStatsWidget(
                onResetStats: () {
                  ref
                      .read(ticTacToeStatsProvider.notifier)
                      .resetStats();
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
