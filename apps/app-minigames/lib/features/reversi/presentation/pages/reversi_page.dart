import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/reversi_entities.dart';
import '../providers/reversi_controller.dart';
import '../widgets/reversi_widgets.dart';

class ReversiPage extends ConsumerWidget {
  const ReversiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reversiControllerProvider);
    final notifier = ref.read(reversiControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Reversi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: notifier.reset,
          ),
        ],
      ),
      body: Column(
        children: [
          // Score
          Padding(
            padding: const EdgeInsets.all(16),
            child: ScoreDisplay(
              blackCount: state.blackCount,
              whiteCount: state.whiteCount,
              currentPlayer: state.currentPlayer,
              isGameOver: state.isGameOver,
            ),
          ),

          // Status
          if (state.isGameOver)
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.winner != null
                    ? '${state.winner == ReversiPlayer.black ? "Preto" : "Branco"} Venceu!'
                    : 'Empate!',
                style: TextStyle(
                  color: state.winner == ReversiPlayer.black
                      ? Colors.grey.shade300
                      : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Vez: ${state.currentPlayer == ReversiPlayer.black ? "Preto" : "Branco"}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),

          // Board
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.brown.shade800, width: 8),
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
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Cerque as peças do oponente para virá-las',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
