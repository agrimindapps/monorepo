import 'package:flutter/material.dart';
import '../../domain/entities/position_entity.dart';
import '../../domain/entities/sudoku_grid_entity.dart';
import 'sudoku_cell_widget.dart';

class SudokuGridWidget extends StatelessWidget {
  final SudokuGridEntity grid;
  final PositionEntity? selectedCell;
  final Function(int row, int col) onCellTap;

  const SudokuGridWidget({
    super.key,
    required this.grid,
    required this.selectedCell,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = (screenWidth * 0.95).clamp(300.0, 500.0);
    final cellSize = gridSize / 9;

    return Container(
      width: gridSize,
      height: gridSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: List.generate(9, (row) {
          return Expanded(
            child: Row(
              children: List.generate(9, (col) {
                final cell = grid.getCell(row, col);
                final isSelected = selectedCell?.row == row &&
                    selectedCell?.col == col;

                return Expanded(
                  child: SudokuCellWidget(
                    cell: cell,
                    isSelected: isSelected,
                    cellSize: cellSize,
                    onTap: () => onCellTap(row, col),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
