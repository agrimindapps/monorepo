import 'package:injectable/injectable.dart';

import '../entities/enums.dart';
import '../entities/grid_entity.dart';
import '../entities/position_entity.dart';
import '../entities/tile_entity.dart';

/// Service responsible for processing tile movement in a single line
///
/// Handles:
/// - Tile merging logic
/// - Movement along rows/columns
/// - Score calculation from merges
/// - Animation type determination
@lazySingleton
class LineMoverService {
  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Processes movement and merging for a single line of tiles
  ///
  /// [line] - Array of tiles in row/column (may contain nulls)
  /// [fixedCoordinate] - The row (for horizontal) or col (for vertical) that stays constant
  /// [isRow] - true for horizontal movement, false for vertical
  /// [calculateVaryingCoordinate] - Function to compute the changing coordinate
  ///
  /// Returns result with processed tiles, score gained, and movement flag
  LineProcessResult processLine({
    required List<TileEntity?> line,
    required int fixedCoordinate,
    required bool isRow,
    required int Function(int) calculateVaryingCoordinate,
  }) {
    final List<TileEntity> processedTiles = [];
    final mergedIds = <String>{};
    int scoreGained = 0;
    bool moved = false;

    // Extract non-null tiles
    final nonEmptyTiles = line.whereType<TileEntity>().toList();

    if (nonEmptyTiles.isEmpty) {
      return LineProcessResult(
        tiles: [],
        scoreGained: 0,
        moved: false,
        mergedIds: {},
      );
    }

    // Store original positions for movement detection
    final originalPositions = <String, PositionEntity>{};
    for (final tile in nonEmptyTiles) {
      originalPositions[tile.id] = tile.position;
    }

    // Process merges and movement
    int targetIndex = 0;
    int i = 0;

    while (i < nonEmptyTiles.length) {
      final currentTile = nonEmptyTiles[i];

      // Check if we can merge with next tile
      if (canMergeWithNext(nonEmptyTiles, i)) {
        final mergeResult = mergeTiles(
          currentTile: currentTile,
          nextTile: nonEmptyTiles[i + 1],
          targetIndex: targetIndex,
          fixedCoordinate: fixedCoordinate,
          isRow: isRow,
          calculateVaryingCoordinate: calculateVaryingCoordinate,
        );

        processedTiles.add(mergeResult.tile);
        mergedIds.addAll(mergeResult.mergedIds);
        scoreGained += mergeResult.scoreGained;
        moved = true;

        i += 2; // Skip both merged tiles
        targetIndex++;
      } else {
        // Just move tile without merging
        final moveResult = moveTile(
          tile: currentTile,
          targetIndex: targetIndex,
          fixedCoordinate: fixedCoordinate,
          isRow: isRow,
          calculateVaryingCoordinate: calculateVaryingCoordinate,
          originalPosition: originalPositions[currentTile.id]!,
        );

        processedTiles.add(moveResult.tile);

        if (moveResult.actuallyMoved) {
          moved = true;
        }

        i++;
        targetIndex++;
      }
    }

    return LineProcessResult(
      tiles: processedTiles,
      scoreGained: scoreGained,
      moved: moved,
      mergedIds: mergedIds,
    );
  }

  // ============================================================================
  // Merge Operations
  // ============================================================================

  /// Checks if current tile can merge with next tile in line
  bool canMergeWithNext(List<TileEntity> tiles, int currentIndex) {
    if (currentIndex + 1 >= tiles.length) {
      return false;
    }

    return tiles[currentIndex].value == tiles[currentIndex + 1].value;
  }

  /// Merges two tiles into one with doubled value
  MergeResult mergeTiles({
    required TileEntity currentTile,
    required TileEntity nextTile,
    required int targetIndex,
    required int fixedCoordinate,
    required bool isRow,
    required int Function(int) calculateVaryingCoordinate,
  }) {
    final mergedValue = currentTile.value * 2;

    final newPosition = calculatePosition(
      targetIndex: targetIndex,
      fixedCoordinate: fixedCoordinate,
      isRow: isRow,
      calculateVaryingCoordinate: calculateVaryingCoordinate,
    );

    final mergedTile = TileEntity(
      id: currentTile.id, // Keep first tile's ID
      value: mergedValue,
      position: newPosition,
      animationType: AnimationType.merge,
    );

    return MergeResult(
      tile: mergedTile,
      scoreGained: mergedValue,
      mergedIds: {currentTile.id, nextTile.id},
    );
  }

  // ============================================================================
  // Move Operations
  // ============================================================================

  /// Moves a tile to target position without merging
  MoveResult moveTile({
    required TileEntity tile,
    required int targetIndex,
    required int fixedCoordinate,
    required bool isRow,
    required int Function(int) calculateVaryingCoordinate,
    required PositionEntity originalPosition,
  }) {
    final newPosition = calculatePosition(
      targetIndex: targetIndex,
      fixedCoordinate: fixedCoordinate,
      isRow: isRow,
      calculateVaryingCoordinate: calculateVaryingCoordinate,
    );

    final actuallyMoved = !originalPosition.isSameAs(newPosition);

    final movedTile = tile.copyWith(
      position: newPosition,
      animationType: actuallyMoved ? AnimationType.move : AnimationType.none,
    );

    return MoveResult(
      tile: movedTile,
      actuallyMoved: actuallyMoved,
    );
  }

  /// Calculates new position for tile based on target index
  PositionEntity calculatePosition({
    required int targetIndex,
    required int fixedCoordinate,
    required bool isRow,
    required int Function(int) calculateVaryingCoordinate,
  }) {
    if (isRow) {
      return PositionEntity(
        row: fixedCoordinate,
        col: calculateVaryingCoordinate(targetIndex),
      );
    } else {
      return PositionEntity(
        row: calculateVaryingCoordinate(targetIndex),
        col: fixedCoordinate,
      );
    }
  }

  // ============================================================================
  // Grid Processing
  // ============================================================================

  /// Processes entire grid for given direction
  GridProcessResult processGrid({
    required GridEntity grid,
    required Direction direction,
  }) {
    final size = grid.size;
    final matrix = grid.toMatrix();

    final List<TileEntity> allNewTiles = [];
    final mergedTileIds = <String>{};
    int totalScoreGained = 0;
    bool anyMoved = false;

    switch (direction) {
      case Direction.left:
        for (int row = 0; row < size; row++) {
          final result = processLine(
            line: matrix[row],
            fixedCoordinate: row,
            isRow: true,
            calculateVaryingCoordinate: (col) => col,
          );
          _accumulateResults(
              result, allNewTiles, mergedTileIds, totalScoreGained, anyMoved);
          totalScoreGained += result.scoreGained;
          anyMoved = anyMoved || result.moved;
        }
        break;

      case Direction.right:
        for (int row = 0; row < size; row++) {
          final result = processLine(
            line: matrix[row].reversed.toList(),
            fixedCoordinate: row,
            isRow: true,
            calculateVaryingCoordinate: (col) => size - 1 - col,
          );
          _accumulateResults(
              result, allNewTiles, mergedTileIds, totalScoreGained, anyMoved);
          totalScoreGained += result.scoreGained;
          anyMoved = anyMoved || result.moved;
        }
        break;

      case Direction.up:
        for (int col = 0; col < size; col++) {
          final column = List.generate(size, (row) => matrix[row][col]);
          final result = processLine(
            line: column,
            fixedCoordinate: col,
            isRow: false,
            calculateVaryingCoordinate: (row) => row,
          );
          _accumulateResults(
              result, allNewTiles, mergedTileIds, totalScoreGained, anyMoved);
          totalScoreGained += result.scoreGained;
          anyMoved = anyMoved || result.moved;
        }
        break;

      case Direction.down:
        for (int col = 0; col < size; col++) {
          final column =
              List.generate(size, (row) => matrix[row][col]).reversed.toList();
          final result = processLine(
            line: column,
            fixedCoordinate: col,
            isRow: false,
            calculateVaryingCoordinate: (row) => size - 1 - row,
          );
          _accumulateResults(
              result, allNewTiles, mergedTileIds, totalScoreGained, anyMoved);
          totalScoreGained += result.scoreGained;
          anyMoved = anyMoved || result.moved;
        }
        break;
    }

    return GridProcessResult(
      tiles: allNewTiles,
      scoreGained: totalScoreGained,
      moved: anyMoved,
      mergedIds: mergedTileIds,
    );
  }

  /// Helper to accumulate results from line processing
  void _accumulateResults(
    LineProcessResult result,
    List<TileEntity> allTiles,
    Set<String> allMergedIds,
    int totalScore,
    bool anyMoved,
  ) {
    allTiles.addAll(result.tiles);
    allMergedIds.addAll(result.mergedIds);
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets statistics about line processing
  LineStatistics getLineStatistics(List<TileEntity?> line) {
    final nonEmpty = line.whereType<TileEntity>().toList();
    final values = nonEmpty.map((t) => t.value).toList();

    int possibleMerges = 0;
    for (int i = 0; i < nonEmpty.length - 1; i++) {
      if (nonEmpty[i].value == nonEmpty[i + 1].value) {
        possibleMerges++;
        i++; // Skip next tile as it would be consumed by merge
      }
    }

    return LineStatistics(
      totalTiles: nonEmpty.length,
      emptySpaces: line.length - nonEmpty.length,
      possibleMerges: possibleMerges,
      values: values,
      maxValue: values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b),
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of processing a single line
class LineProcessResult {
  final List<TileEntity> tiles;
  final int scoreGained;
  final bool moved;
  final Set<String> mergedIds;

  const LineProcessResult({
    required this.tiles,
    required this.scoreGained,
    required this.moved,
    required this.mergedIds,
  });
}

/// Result of merging two tiles
class MergeResult {
  final TileEntity tile;
  final int scoreGained;
  final Set<String> mergedIds;

  const MergeResult({
    required this.tile,
    required this.scoreGained,
    required this.mergedIds,
  });
}

/// Result of moving a tile
class MoveResult {
  final TileEntity tile;
  final bool actuallyMoved;

  const MoveResult({
    required this.tile,
    required this.actuallyMoved,
  });
}

/// Result of processing entire grid
class GridProcessResult {
  final List<TileEntity> tiles;
  final int scoreGained;
  final bool moved;
  final Set<String> mergedIds;

  const GridProcessResult({
    required this.tiles,
    required this.scoreGained,
    required this.moved,
    required this.mergedIds,
  });
}

/// Statistics about a line of tiles
class LineStatistics {
  final int totalTiles;
  final int emptySpaces;
  final int possibleMerges;
  final List<int> values;
  final int maxValue;

  const LineStatistics({
    required this.totalTiles,
    required this.emptySpaces,
    required this.possibleMerges,
    required this.values,
    required this.maxValue,
  });
}
