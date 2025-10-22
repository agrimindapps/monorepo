import 'package:flutter/material.dart';

import '../../domain/entities/grid_entity.dart';
import 'tile_widget.dart';

/// Widget that displays the game grid
class GridWidget extends StatelessWidget {
  final GridEntity grid;
  final double cellSize;
  final double spacing;

  const GridWidget({
    super.key,
    required this.grid,
    this.cellSize = 70.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final size = grid.size;
    final gridSize = (cellSize * size) + (spacing * (size + 1));

    return Container(
      width: gridSize,
      height: gridSize,
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Background grid (empty cells)
          _buildBackgroundGrid(size),
          // Tiles
          ...grid.tiles.map((tile) => TileWidget(
                tile: tile,
                cellSize: cellSize,
                spacing: spacing,
              )),
        ],
      ),
    );
  }

  /// Builds the background grid showing empty cells
  Widget _buildBackgroundGrid(int size) {
    return Padding(
      padding: EdgeInsets.all(spacing),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
        ),
        itemCount: size * size,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFCDC1B4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}
