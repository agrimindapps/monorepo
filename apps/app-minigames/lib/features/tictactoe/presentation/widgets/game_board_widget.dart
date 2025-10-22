import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import 'board_cell_widget.dart';

/// Widget that displays the TicTacToe game board
class GameBoardWidget extends StatelessWidget {
  final GameState gameState;
  final Function(int row, int col) onCellTapped;

  const GameBoardWidget({
    super.key,
    required this.gameState,
    required this.onCellTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final row = index ~/ 3;
          final col = index % 3;
          final isWinningCell = gameState.winningLine?.contains(index) ?? false;

          return BoardCellWidget(
            player: gameState.board[row][col],
            isWinningCell: isWinningCell,
            onTap: gameState.isInProgress && gameState.board[row][col].index == 2
                ? () => onCellTapped(row, col)
                : null,
          );
        },
      ),
    );
  }
}
