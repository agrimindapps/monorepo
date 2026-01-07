import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../domain/entities/damas_entities.dart';
import '../providers/damas_controller.dart';
import '../widgets/damas_widgets.dart';

class DamasPage extends ConsumerWidget {
  const DamasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(damasControllerProvider);
    final notifier = ref.read(damasControllerProvider.notifier);

    return GamePageLayout(
      title: 'Damas',
      accentColor: const Color(0xFF795548),
      instructions: 'Capture todas as peças do oponente!\n\n'
          '🔴 Vermelho vs ⚫ Preto\n'
          '↗️ Mova na diagonal\n'
          '👑 Peças viram damas no fim',
      maxGameWidth: 500,
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
            // Status
            if (state.winner != null)
              Text(
                '🎉 ${state.winner == Player.red ? "Vermelho" : "Preto"} Venceu!',
                style: TextStyle(
                  color: state.winner == Player.red ? Colors.red : Colors.grey,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Vez: ',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Container(
                    width: 26,
                    height: 26,
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
            const SizedBox(height: 8),
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
                  style: TextStyle(color: Colors.yellow, fontSize: 14),
                ),
              ),
            const SizedBox(height: 12),

            // Board
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown.shade800, width: 6),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPieceCount(Color color, int count) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'x $count',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}
