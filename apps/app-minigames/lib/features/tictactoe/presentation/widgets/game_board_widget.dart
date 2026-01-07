import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/game_state.dart';
import 'board_cell_widget.dart';

/// Widget that displays the TicTacToe game board
class GameBoardWidget extends StatefulWidget {
  final GameState gameState;
  final Function(int row, int col) onCellTapped;

  const GameBoardWidget({
    super.key,
    required this.gameState,
    required this.onCellTapped,
  });

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  // Focus nodes for keyboard navigation
  late List<List<FocusNode>> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(
      3,
      (row) => List.generate(3, (col) => FocusNode()),
    );
  }

  @override
  void dispose() {
    for (var row in _focusNodes) {
      for (var node in row) {
        node.dispose();
      }
    }
    super.dispose();
  }

  void _handleKeyEvent(int row, int col, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight && col < 2) {
        _focusNodes[row][col + 1].requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && col > 0) {
        _focusNodes[row][col - 1].requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && row < 2) {
        _focusNodes[row + 1][col].requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && row > 0) {
        _focusNodes[row - 1][col].requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (widget.gameState.isInProgress &&
            widget.gameState.board[row][col].index == 2) {
          widget.onCellTapped(row, col);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final row = index ~/ 3;
        final col = index % 3;
        final isWinningCell = widget.gameState.winningLine?.contains(index) ?? false;

        return RawKeyboardListener(
          focusNode: _focusNodes[row][col],
          onKey: (event) => _handleKeyEvent(row, col, event),
          child: BoardCellWidget(
            player: widget.gameState.board[row][col],
            isWinningCell: isWinningCell,
            onTap: widget.gameState.isInProgress && widget.gameState.board[row][col].index == 2
                ? () => widget.onCellTapped(row, col)
                : null,
            focusNode: _focusNodes[row][col],
          ),
        );
      },
    );
  }
}
