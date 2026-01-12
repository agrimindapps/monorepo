import 'package:flutter/material.dart';
import 'tictactoe_high_scores_page.dart';
import 'tictactoe_settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/esc_keyboard_wrapper.dart';
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

    return GamePageLayout(
      title: 'Jogo da Velha',
      accentColor: const Color(0xFF6A11CB),
      instructions: 'Três em linha vence!\n\n'
          '❌ Jogador X começa\n'
          '⭕ Alternância de turnos\n'
          '🏆 Faça 3 em linha para vencer\n'
          '🤖 Jogue contra a IA ou amigo',
      maxGameWidth: 500,
      scrollable: true, // Flutter widget game needs scrolling
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicTacToeHighScoresPage()),
            );
          },
          tooltip: 'Estatísticas',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicTacToeSettingsPage()),
            );
          },
          tooltip: 'Configurações',
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart, color: Colors.white),
          onPressed: () => _showStatsDialog(context, ref),
          tooltip: 'Ver Estatísticas',
        ),
      ],
      child: gameState.when(
        data: (state) => EscKeyboardWrapper(
          onEscPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text('Pausado'),
                content: const Text('Pressione ESC para continuar ou Reiniciar'),
                actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicTacToeHighScoresPage()),
            );
          },
          tooltip: 'Estatísticas',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicTacToeSettingsPage()),
            );
          },
          tooltip: 'Configurações',
        ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continuar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(ticTacToeGameProvider.notifier).restartGame();
                    },
                    child: const Text('Reiniciar'),
                  ),
                ],
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6A11CB).withValues(alpha: 0.3),
                ),
              ),
              child: GameControlsWidget(
                gameState: state,
                onGameModeChanged: (mode) {
                  ref.read(ticTacToeGameProvider.notifier).changeGameMode(mode);
                },
                onDifficultyChanged: (difficulty) {
                  ref.read(ticTacToeGameProvider.notifier).changeDifficulty(difficulty);
                },
                onRestart: () {
                  ref.read(ticTacToeGameProvider.notifier).restartGame();
                },
              ),
            ),
            const SizedBox(height: 20),
            if (state.isInProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Vez de: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      Text(
                        state.currentPlayer.symbol,
                        style: TextStyle(
                          color: state.currentPlayer.color,
                          fontSize: 24,
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
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        state.result.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(ticTacToeGameProvider.notifier).restartGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A11CB),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Jogar Novamente'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2A2A3E).withValues(alpha: 0.6),
                        const Color(0xFF1F1F2E).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6A11CB).withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A11CB).withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: GameBoardWidget(
                    gameState: state,
                    onCellTapped: (row, col) {
                      ref.read(ticTacToeGameProvider.notifier).makeMove(row, col);
                    },
                  ),
                ),
              ),
            ],
          ),
          ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6A11CB)),
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
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(ticTacToeGameProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                ),
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
                  ref.read(ticTacToeStatsProvider.notifier).resetStats();
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
