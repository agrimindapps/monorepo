import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/campo_minado_game_notifier.dart';
import 'cell_widget.dart';

/// Main minefield grid widget
class MinefieldWidget extends ConsumerWidget {
  const MinefieldWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(campoMinadoGameProvider);

    // Calculate cell size based on grid dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth - 32; // Padding
    final cellSize = (maxWidth / gameState.cols).clamp(20.0, 40.0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[600]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          gameState.rows,
          (row) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              gameState.cols,
              (col) => CellWidget(
                cell: gameState.grid[row][col],
                size: cellSize,
                isPaused: gameState.isPaused,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
