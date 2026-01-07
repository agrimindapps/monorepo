import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/damas_entities.dart';
import '../providers/damas_controller.dart';
import '../widgets/damas_widgets.dart';

class DamasPage extends ConsumerWidget {
  const DamasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(damasControllerProvider);
    final notifier = ref.read(damasControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Damas'),
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
          // Status
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (state.winner != null)
                  Text(
                    '${state.winner == Player.red ? "Vermelho" : "Preto"} Venceu!',
                    style: TextStyle(
                      color: state.winner == Player.red ? Colors.red : Colors.grey,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vez: ',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.currentPlayer == Player.red
                              ? Colors.red
                              : Colors.grey.shade900,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPieceCount(Colors.red, state.redCount),
                    _buildPieceCount(Colors.grey.shade900, state.blackCount),
                  ],
                ),
                if (state.mustContinueCapture)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Continue capturando!',
                      style: TextStyle(color: Colors.yellow, fontSize: 16),
                    ),
                  ),
              ],
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
                    border: Border.all(color: Colors.brown.shade800, width: 8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final pos = Position(row, col);
                      final piece = state.board[row][col];
                      final isDark = (row + col) % 2 == 1;
                      final isSelected = state.selectedPosition == pos;
                      final isValidMove = state.validMoves.any((m) => m.to == pos);

                      return BoardSquare(
                        isDark: isDark,
                        isSelected: isSelected,
                        isValidMove: isValidMove,
                        onTap: () => notifier.selectPosition(pos),
                        child: piece != null
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return PieceWidget(
                                    piece: piece,
                                    isSelected: isSelected,
                                    size: constraints.maxWidth * 0.8,
                                  );
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieceCount(Color color, int count) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'x $count',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}
