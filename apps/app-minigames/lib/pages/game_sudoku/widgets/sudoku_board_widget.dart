// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/models/game_logic.dart';
import 'sudoku_cell.dart';

class SudokuBoardWidget extends StatelessWidget {
  final SudokuGameLogic gameLogic;
  final Function(int, int) onCellTap;

  const SudokuBoardWidget({
    super.key,
    required this.gameLogic,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5.0,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: SudokuGameLogic.boardSize,
          childAspectRatio: 1.0,
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
        ),
        itemCount: SudokuGameLogic.boardSize * SudokuGameLogic.boardSize,
        itemBuilder: (context, index) {
          final row = index ~/ SudokuGameLogic.boardSize;
          final col = index % SudokuGameLogic.boardSize;

          return SudokuCellWidget(
            value: gameLogic.board[row][col],
            isSelected:
                row == gameLogic.selectedRow && col == gameLogic.selectedCol,
            isEditable: gameLogic.isEditable[row][col],
            hasConflict: gameLogic.hasConflict[row][col],
            notes: gameLogic.notes[row][col],
            onTap: () => onCellTap(row, col),
            borderColor: _getBorderColor(row, col),
            borderWidth: _getBorderWidth(row, col),
          );
        },
      ),
    );
  }

  Color _getBorderColor(int row, int col) {
    return Colors.black;
  }

  double _getBorderWidth(int row, int col) {
    final isRightEdge =
        (col + 1) % 3 == 0 && col < SudokuGameLogic.boardSize - 1;
    final isBottomEdge =
        (row + 1) % 3 == 0 && row < SudokuGameLogic.boardSize - 1;
    final isOuterEdge = row == 0 ||
        row == SudokuGameLogic.boardSize - 1 ||
        col == 0 ||
        col == SudokuGameLogic.boardSize - 1;

    if (isOuterEdge) return 2.0;
    if (isRightEdge || isBottomEdge) return 2.0;
    return 1.0;
  }
}
