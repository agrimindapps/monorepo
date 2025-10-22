import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import 'grid_cell_widget.dart';

/// Widget displaying the word search grid
class WordGridWidget extends StatelessWidget {
  final GameState gameState;
  final Function(int row, int col) onCellTap;

  const WordGridWidget({
    super.key,
    required this.gameState,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final gridSize = gameState.gridSize;

    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ gridSize;
          final col = index % gridSize;
          final letter = gameState.grid[row][col];

          return GridCellWidget(
            letter: letter,
            row: row,
            col: col,
            gameState: gameState,
            onTap: () => onCellTap(row, col),
          );
        },
      ),
    );
  }
}
