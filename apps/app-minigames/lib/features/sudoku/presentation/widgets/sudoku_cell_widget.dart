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
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(theme, isDark),
          border: Border(
            right: BorderSide(
              color: isDark 
                  ? (cell.col % 3 == 2 ? Colors.white70 : Colors.white24)
                  : (cell.col % 3 == 2 ? Colors.black : Colors.grey.shade400),
              width: cell.col % 3 == 2 ? 2 : 0.5,
            ),
            bottom: BorderSide(
              color: isDark 
                  ? (cell.row % 3 == 2 ? Colors.white70 : Colors.white24)
                  : (cell.row % 3 == 2 ? Colors.black : Colors.grey.shade400),
              width: cell.row % 3 == 2 ? 2 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: cell.isEmpty ? _buildNotes(theme, isDark) : _buildValue(theme, isDark),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme, bool isDark) {
    // Base colors for dark/light theme
    final normalColor = isDark ? const Color(0xFF2A2A3E) : Colors.white;
    final alternateColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5);
    
    // Determine if this cell is in an alternate 3x3 box (checkerboard pattern for boxes)
    final boxRow = cell.row ~/ 3;
    final boxCol = cell.col ~/ 3;
    final isAlternateBox = (boxRow + boxCol) % 2 == 1;
    
    if (cell.hasConflict) {
      return isDark ? const Color(0xFF5C2A2A) : Colors.red.shade100;
    }

    switch (cell.state) {
      case CellState.selected:
        return isDark 
            ? const Color(0xFF4A3C6E) // Purple highlight for selected
            : theme.primaryColor.withValues(alpha: 0.3);
      case CellState.highlighted:
        return isDark 
            ? const Color(0xFF3A3A5E) // Subtle highlight for same row/col
            : theme.primaryColor.withValues(alpha: 0.1);
      case CellState.sameNumber:
        return isDark 
            ? const Color(0xFF3A4A5E) // Blue-ish for same number
            : theme.primaryColor.withValues(alpha: 0.2);
      case CellState.error:
        return isDark ? const Color(0xFF5C2A2A) : Colors.red.shade200;
      case CellState.normal:
        return isAlternateBox ? alternateColor : normalColor;
    }
  }

  Widget _buildValue(ThemeData theme, bool isDark) {
    Color textColor;
    
    if (cell.isFixed) {
      // Fixed numbers (original puzzle) - white/black depending on theme
      textColor = isDark ? Colors.white : Colors.black;
    } else if (cell.hasConflict) {
      // Conflicting numbers - red
      textColor = Colors.red.shade400;
    } else {
      // User-entered numbers - accent color
      textColor = isDark ? const Color(0xFF9C7CF2) : theme.primaryColor;
    }
    
    return Text(
      cell.value.toString(),
      style: TextStyle(
        fontSize: cellSize * 0.5,
        fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.w500,
        color: textColor,
      ),
    );
  }

  Widget _buildNotes(ThemeData theme, bool isDark) {
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
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                )
              : null,
        );
      }),
    );
  }
}
