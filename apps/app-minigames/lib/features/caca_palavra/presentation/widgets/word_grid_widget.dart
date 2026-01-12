import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import 'grid_cell_widget.dart';

/// Widget displaying the word search grid with drag selection
class WordGridWidget extends StatefulWidget {
  final GameState gameState;
  final Function(int row, int col) onDragStart;
  final Function(int row, int col) onDragUpdate;
  final VoidCallback onDragEnd;

  const WordGridWidget({
    super.key,
    required this.gameState,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<WordGridWidget> createState() => _WordGridWidgetState();
}

class _WordGridWidgetState extends State<WordGridWidget> {
  final Map<int, GlobalKey> _cellKeys = {};

  @override
  Widget build(BuildContext context) {
    final gridSize = widget.gameState.gridSize;

    return GestureDetector(
      onPanStart: (details) => _handlePanStart(details.localPosition),
      onPanUpdate: (details) => _handlePanUpdate(details.localPosition),
      onPanEnd: (_) => widget.onDragEnd(),
      child: AspectRatio(
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
            final letter = widget.gameState.grid[row][col];

            // Create unique key for each cell
            final cellKey = _cellKeys.putIfAbsent(index, () => GlobalKey());

            return GridCellWidget(
              key: cellKey,
              letter: letter,
              row: row,
              col: col,
              gameState: widget.gameState,
            );
          },
        ),
      ),
    );
  }

  void _handlePanStart(Offset position) {
    final cellCoords = _getCellAtPosition(position);
    if (cellCoords != null) {
      widget.onDragStart(cellCoords.$1, cellCoords.$2);
    }
  }

  void _handlePanUpdate(Offset position) {
    final cellCoords = _getCellAtPosition(position);
    if (cellCoords != null) {
      widget.onDragUpdate(cellCoords.$1, cellCoords.$2);
    }
  }

  (int, int)? _getCellAtPosition(Offset position) {
    for (final entry in _cellKeys.entries) {
      final key = entry.value;
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      
      if (renderBox != null) {
        final cellPosition = renderBox.localToGlobal(Offset.zero);
        final cellSize = renderBox.size;
        
        // Convert local position to global
        final widgetBox = context.findRenderObject() as RenderBox?;
        if (widgetBox == null) continue;
        
        final globalPosition = widgetBox.localToGlobal(position);
        
        // Check if position is within cell bounds
        if (globalPosition.dx >= cellPosition.dx &&
            globalPosition.dx <= cellPosition.dx + cellSize.width &&
            globalPosition.dy >= cellPosition.dy &&
            globalPosition.dy <= cellPosition.dy + cellSize.height) {
          final index = entry.key;
          final gridSize = widget.gameState.gridSize;
          final row = index ~/ gridSize;
          final col = index % gridSize;
          return (row, col);
        }
      }
    }
    return null;
  }
}
