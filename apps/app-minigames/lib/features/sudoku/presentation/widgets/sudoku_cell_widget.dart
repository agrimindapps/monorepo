import 'package:flutter/material.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/sudoku_cell_entity.dart';

class SudokuCellWidget extends StatelessWidget {
  final SudokuCellEntity cell;
  final bool isSelected;
  final double cellSize;
  final VoidCallback onTap;

  const SudokuCellWidget({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.cellSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(theme),
          border: Border(
            right: BorderSide(
              color: cell.col % 3 == 2 ? Colors.black : Colors.grey.shade400,
              width: cell.col % 3 == 2 ? 2 : 0.5,
            ),
            bottom: BorderSide(
              color: cell.row % 3 == 2 ? Colors.black : Colors.grey.shade400,
              width: cell.row % 3 == 2 ? 2 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: cell.isEmpty
              ? _buildNotes(theme)
              : _buildValue(theme),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (cell.hasConflict) {
      return Colors.red.shade100;
    }

    switch (cell.state) {
      case CellState.selected:
        return theme.primaryColor.withOpacity(0.3);
      case CellState.highlighted:
        return theme.primaryColor.withOpacity(0.1);
      case CellState.sameNumber:
        return theme.primaryColor.withOpacity(0.2);
      case CellState.error:
        return Colors.red.shade200;
      case CellState.normal:
        return Colors.white;
    }
  }

  Widget _buildValue(ThemeData theme) {
    return Text(
      cell.value.toString(),
      style: TextStyle(
        fontSize: cellSize * 0.5,
        fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.normal,
        color: cell.isFixed
            ? Colors.black
            : (cell.hasConflict ? Colors.red : theme.primaryColor),
      ),
    );
  }

  Widget _buildNotes(ThemeData theme) {
    if (cell.notes.isEmpty) return const SizedBox();

    return GridView.count(
      crossAxisCount: 3,
      padding: EdgeInsets.all(cellSize * 0.05),
      children: List.generate(9, (index) {
        final number = index + 1;
        final hasNote = cell.notes.contains(number);

        return Center(
          child: hasNote
              ? Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: cellSize * 0.2,
                    color: Colors.grey.shade600,
                  ),
                )
              : null,
        );
      }),
    );
  }
}
