// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_theme.dart';
import 'package:app_minigames/models/game_board.dart';
import 'board_cell.dart';

class GameBoardWidget extends StatefulWidget {
  final GameBoard gameBoard;
  final Function(int row, int col) onCellTap;

  const GameBoardWidget({
    super.key,
    required this.gameBoard,
    required this.onCellTap,
  });
  
  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _winAnimationController;
  late Animation<double> _winAnimation;
  
  @override
  void initState() {
    super.initState();
    _winAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _winAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _winAnimationController,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _winAnimationController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(GameBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animar quando há uma vitória
    if (widget.gameBoard.result != GameResult.inProgress &&
        oldWidget.gameBoard.result == GameResult.inProgress) {
      _winAnimationController.forward();
    }
    
    // Reset animation quando jogo reinicia
    if (widget.gameBoard.result == GameResult.inProgress &&
        oldWidget.gameBoard.result != GameResult.inProgress) {
      _winAnimationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardSize = GameTheme.getGameBoardSize(context);
    final cellPadding = GameTheme.getCellPadding(context);
    
    return AnimatedBuilder(
      animation: _winAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_winAnimation.value * 0.05),
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GameTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.gameBoard.result != GameResult.inProgress
                  ? [
                      BoxShadow(
                        color: widget.gameBoard.currentPlayer.color.withValues(alpha: 0.3),
                        blurRadius: 20 + (_winAnimation.value * 20),
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : GameTheme.cardShadow,
              ),
              child: Padding(
                padding: EdgeInsets.all(cellPadding),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: cellPadding,
                    mainAxisSpacing: cellPadding,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final row = index ~/ 3;
                    final col = index % 3;
                    final player = widget.gameBoard.board[row][col];
                    final isWinningCell =
                        widget.gameBoard.winningLine?.contains(index) ?? false;

                    return BoardCell(
                      player: player,
                      isWinningCell: isWinningCell,
                      row: row,
                      col: col,
                      onTap: widget.gameBoard.result == GameResult.inProgress &&
                              player == Player.none
                          ? () => widget.onCellTap(row, col)
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
