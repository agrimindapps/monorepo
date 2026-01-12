import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../../domain/entities/connect_four_score.dart';
import '../providers/connect_four_controller.dart';
import '../providers/connect_four_data_providers.dart';
import 'connect_four_high_scores_page.dart';
import 'connect_four_settings_page.dart';

class ConnectFourPage extends ConsumerStatefulWidget {
  const ConnectFourPage({super.key});

  @override
  ConsumerState<ConnectFourPage> createState() => _ConnectFourPageState();
}

class _ConnectFourPageState extends ConsumerState<ConnectFourPage> {
  Future<void> _saveScoreAndReset() async {
    final state = ref.read(connectFourControllerProvider);
    
    if ((state.winner != null || state.isDraw) && state.gameStartTime != null) {
      final winner = state.isDraw 
          ? 'Draw' 
          : state.winner == 1 ? 'Player 1' : 'Player 2';
      
      final score = ConnectFourScore(
        winner: winner,
        movesCount: state.movesCount,
        gameDuration: state.gameDuration,
        timestamp: DateTime.now(),
      );

      await ref.read(saveScoreUseCaseProvider).call(score);
      ref.invalidate(connectFourHighScoresProvider);
      ref.invalidate(connectFourStatsProvider);
    }

    ref.read(connectFourControllerProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(connectFourControllerProvider);
    final notifier = ref.read(connectFourControllerProvider.notifier);

    return GamePageLayout(
      title: 'Lig 4',
      accentColor: const Color(0xFF1976D2),
      instructions: 'Conecte 4 peças da mesma cor!\n\n'
          '🔴 Jogador 1 (Vermelho)\n'
          '🟡 Jogador 2 (Amarelo)\n'
          '🎯 Horizontal, vertical ou diagonal',
      maxGameWidth: 450,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events),
          tooltip: 'High Scores',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ConnectFourHighScoresPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Configurações',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ConnectFourSettingsPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: state.winner != null || state.isDraw ? _saveScoreAndReset : notifier.reset,
          tooltip: 'Reiniciar',
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Header
            _buildStatus(state),
            const SizedBox(height: 16),
            
            // Game Board
            AspectRatio(
              aspectRatio: 7 / 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade700, width: 6),
                ),
                child: Row(
                  children: List.generate(7, (colIndex) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => notifier.dropChip(colIndex),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: List.generate(6, (rowIndex) {
                            final cellValue = state.board[rowIndex][colIndex];
                            final isWinning = state.winningLine.any(
                              (pos) => pos[0] == rowIndex && pos[1] == colIndex
                            );

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getCellColor(cellValue),
                                  border: isWinning 
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(2, 2),
                                      blurRadius: 2,
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(ConnectFourState state) {
    if (state.winner != null) {
      return Column(
        children: [
          Text(
            state.winner == 1 ? '🎉 Jogador 1 Venceu!' : '🎉 Jogador 2 Venceu!',
            style: TextStyle(
              color: state.winner == 1 ? Colors.red : Colors.yellow,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    
    if (state.isDraw) {
      return const Text(
        '🤝 Empate!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Vez do: ',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.currentPlayer == 1 ? Colors.red : Colors.yellow,
          ),
        ),
      ],
    );
  }

  Color _getCellColor(int value) {
    switch (value) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return const Color(0xFF1A1A2E);
    }
  }
}
