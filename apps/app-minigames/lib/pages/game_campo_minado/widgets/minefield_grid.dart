// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart' as constants;
import '../providers/game_state_provider.dart';
import 'cell_widget.dart';

/// Grid widget that displays the minesweeper field
class MinefieldGrid extends StatelessWidget {
  const MinefieldGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameProvider, child) {
        final grid = gameProvider.grid;
        final gameState = gameProvider.gameState;
        
        if (grid.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: constants.GameColors.background,
            borderRadius: BorderRadius.circular(constants.Layout.gridBorderRadius),
            border: Border.all(
              color: Colors.grey[400]!,
              width: constants.Layout.gridBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: constants.VisualFeedback.gridShadowOpacity),
                blurRadius: constants.VisualFeedback.gridShadowBlur,
                offset: const Offset(
                  constants.VisualFeedback.gridShadowOffsetX,
                  constants.VisualFeedback.gridShadowOffsetY,
                ),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(constants.Layout.gridPadding),
            child: RepaintBoundary(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gameProvider.config.cols,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: constants.GameSizes.cellSpacing,
                  mainAxisSpacing: constants.GameSizes.cellSpacing,
                ),
                itemCount: gameProvider.config.totalCells,
                itemBuilder: (context, index) {
                  final row = index ~/ gameProvider.config.cols;
                  final col = index % gameProvider.config.cols;
                  final cell = grid[row][col];

                  return CellWidget(
                    key: ValueKey('cell_${row}_$col'),
                    cell: cell,
                    isGameOver: gameState.isGameOver,
                    onTap: () => _handleCellTap(context, gameProvider, row, col),
                    onLongPress: () => _handleCellLongPress(context, gameProvider, row, col),
                    onDoubleTap: () => _handleCellDoubleTap(context, gameProvider, row, col),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCellTap(BuildContext context, GameStateProvider gameProvider, int row, int col) {
    if (!gameProvider.gameState.canInteract) return;
    
    gameProvider.revealCell(row, col);
  }

  void _handleCellLongPress(BuildContext context, GameStateProvider gameProvider, int row, int col) {
    if (!gameProvider.gameState.canInteract) return;
    
    gameProvider.toggleFlag(row, col);
  }

  void _handleCellDoubleTap(BuildContext context, GameStateProvider gameProvider, int row, int col) {
    if (!gameProvider.gameState.canInteract) return;
    
    gameProvider.chordClick(row, col);
  }
}
