import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tictactoe_game_notifier.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_controls_widget.dart';
import '../widgets/game_stats_widget.dart';
import '../../../../widgets/shared/responsive_game_container.dart';

/// Main page for TicTacToe game
/// Uses Riverpod for state management
class TicTacToePage extends ConsumerWidget {
  const TicTacToePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(ticTacToeGameProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Jogo da Velha',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStatsDialog(context, ref),
            tooltip: 'Ver Estatísticas',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB), // Purple
              Color(0xFF2575FC), // Blue
            ],
          ),
        ),
        child: gameState.when(
          data: (state) => SafeArea(
            child: ResponsiveGameContainer(
              // TicTacToe works best with a narrower layout
              maxWidth: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game Controls Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          color: Colors.white.withValues(alpha: 0.9),
                          child: Padding(
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
                        ),

                        const SizedBox(height: 24),

                        // Turn Indicator or Result
                        if (state.isInProgress)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Vez de: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  state.currentPlayer.symbol,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: state.currentPlayer.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),

                        if (!state.isInProgress)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  state.result.message,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(ticTacToeGameProvider.notifier)
                                        .restartGame();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Jogar Novamente'),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Game Board
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
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
                      ],
                    ),
                  ),
                ),
              ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Erro: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
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
