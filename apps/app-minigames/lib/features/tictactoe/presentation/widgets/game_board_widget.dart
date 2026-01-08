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
  // Focus nodes for keyboard navigation - separate from InkWell focus
  late List<List<FocusNode>> _focusNodes;
  int _focusedRow = 0;
  int _focusedCol = 0;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(
      3,
      (row) => List.generate(3, (col) => FocusNode(debugLabel: 'cell_$row$col')),
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

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight && _focusedCol < 2) {
        setState(() => _focusedCol++);
        _focusNodes[_focusedRow][_focusedCol].requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _focusedCol > 0) {
        setState(() => _focusedCol--);
        _focusNodes[_focusedRow][_focusedCol].requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && _focusedRow < 2) {
        setState(() => _focusedRow++);
        _focusNodes[_focusedRow][_focusedCol].requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && _focusedRow > 0) {
        setState(() => _focusedRow--);
        _focusNodes[_focusedRow][_focusedCol].requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (widget.gameState.isInProgress &&
            widget.gameState.board[_focusedRow][_focusedCol].index == 2) {
          widget.onCellTapped(_focusedRow, _focusedCol);
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) => _handleKeyEvent(event),
      child: GridView.builder(
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
          final isFocused = row == _focusedRow && col == _focusedCol;

          return GestureDetector(
            onTap: widget.gameState.isInProgress && widget.gameState.board[row][col].index == 2
                ? () {
                    setState(() {
                      _focusedRow = row;
                      _focusedCol = col;
                    });
                    _focusNodes[row][col].requestFocus();
                    widget.onCellTapped(row, col);
                  }
                : null,
            child: Focus(
              focusNode: _focusNodes[row][col],
              child: BoardCellWidget(
                player: widget.gameState.board[row][col],
                isWinningCell: isWinningCell,
                isFocused: isFocused,
              ),
            ),
          );
        },
      ),
    );
  }
}
