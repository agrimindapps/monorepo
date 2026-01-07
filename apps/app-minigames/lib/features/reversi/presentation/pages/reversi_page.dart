import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../domain/entities/reversi_entities.dart';
import '../providers/reversi_controller.dart';
import '../widgets/reversi_widgets.dart';

class ReversiPage extends ConsumerWidget {
  const ReversiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reversiControllerProvider);
    final notifier = ref.read(reversiControllerProvider.notifier);

    return GamePageLayout(
      title: 'Reversi',
      accentColor: const Color(0xFF2E7D32),
      instructions: 'Cerque as peças do oponente para virá-las!\n\n'
          '⚫ Preto vs ⚪ Branco\n'
          '🔄 Vire em todas as direções\n'
          '🏆 Quem tiver mais peças vence',
      maxGameWidth: 450,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: notifier.reset,
          tooltip: 'Reiniciar',
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score
            ScoreDisplay(
              blackCount: state.blackCount,
              whiteCount: state.whiteCount,
              currentPlayer: state.currentPlayer,
              isGameOver: state.isGameOver,
            ),

            const SizedBox(height: 8),

            // Status
            if (state.isGameOver)
              Text(
                state.winner != null
                    ? '🎉 ${state.winner == ReversiPlayer.black ? "Preto" : "Branco"} Venceu!'
                    : '🤝 Empate!',
                style: TextStyle(
                  color: state.winner == ReversiPlayer.black
                      ? Colors.grey.shade300
                      : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                'Vez: ${state.currentPlayer == ReversiPlayer.black ? "Preto" : "Branco"}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),

            const SizedBox(height: 12),

            // Board
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown.shade800, width: 6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final piece = state.board[row][col];
                      final isValidMove = state.validMoves.any(
                        (m) => m[0] == row && m[1] == col,
                      );

                      return ReversiBoardCell(
                        piece: piece,
                        isValidMove: isValidMove,
                        onTap: () => notifier.makeMove(row, col),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
