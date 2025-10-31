import 'package:injectable/injectable.dart';

import '../entities/grid_entity.dart';
import '../entities/position_entity.dart';

/// Service responsible for checking game over conditions
///
/// Handles:
/// - Detection of available moves
/// - Horizontal merge checking
/// - Vertical merge checking
/// - Game over state determination
@lazySingleton
class GameOverCheckerService {
  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Checks if any valid moves are available
  ///
  /// Returns true if game is over (no moves possible)
  /// Returns false if moves are still available
  bool isGameOver(GridEntity grid) {
    // Quick check: if there are empty positions, game is not over
    if (hasEmptyPositions(grid)) {
      return false;
    }

    // Grid is full, check for possible merges
    return !hasPossibleMerges(grid);
  }

  /// Checks if grid has any empty positions
  bool hasEmptyPositions(GridEntity grid) {
    return grid.getEmptyPositions().isNotEmpty;
  }

  /// Checks if any merges are possible (horizontal or vertical)
  bool hasPossibleMerges(GridEntity grid) {
    return hasHorizontalMerges(grid) || hasVerticalMerges(grid);
  }

  // ============================================================================
  // Horizontal Merge Detection
  // ============================================================================

  /// Checks for possible merges in horizontal direction
  bool hasHorizontalMerges(GridEntity grid) {
    final size = grid.size;

    for (int row = 0; row < size; row++) {
      if (hasHorizontalMergeInRow(grid, row)) {
        return true;
      }
    }

    return false;
  }

  /// Checks for possible merges in a specific row
  bool hasHorizontalMergeInRow(GridEntity grid, int row) {
    final size = grid.size;

    for (int col = 0; col < size - 1; col++) {
      final current = grid.getTileAt(PositionEntity(row: row, col: col));
      final next = grid.getTileAt(PositionEntity(row: row, col: col + 1));

      if (canMergeTiles(current?.value, next?.value)) {
        return true;
      }
    }

    return false;
  }

  // ============================================================================
  // Vertical Merge Detection
  // ============================================================================

  /// Checks for possible merges in vertical direction
  bool hasVerticalMerges(GridEntity grid) {
    final size = grid.size;

    for (int col = 0; col < size; col++) {
      if (hasVerticalMergeInColumn(grid, col)) {
        return true;
      }
    }

    return false;
  }

  /// Checks for possible merges in a specific column
  bool hasVerticalMergeInColumn(GridEntity grid, int col) {
    final size = grid.size;

    for (int row = 0; row < size - 1; row++) {
      final current = grid.getTileAt(PositionEntity(row: row, col: col));
      final next = grid.getTileAt(PositionEntity(row: row + 1, col: col));

      if (canMergeTiles(current?.value, next?.value)) {
        return true;
      }
    }

    return false;
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Checks if two tile values can merge
  ///
  /// Tiles can merge if:
  /// - Both are non-null
  /// - Both have the same value
  bool canMergeTiles(int? value1, int? value2) {
    if (value1 == null || value2 == null) {
      return false;
    }

    return value1 == value2;
  }

  /// Gets detailed game state information
  GameStateInfo getGameStateInfo(GridEntity grid) {
    final emptyPositions = grid.getEmptyPositions();
    final hasEmpty = emptyPositions.isNotEmpty;
    final hasHorizontal = hasHorizontalMerges(grid);
    final hasVertical = hasVerticalMerges(grid);
    final totalMerges = countPossibleMerges(grid);

    return GameStateInfo(
      isGameOver: !hasEmpty && !hasHorizontal && !hasVertical,
      hasEmptyPositions: hasEmpty,
      emptyPositionCount: emptyPositions.length,
      hasHorizontalMerges: hasHorizontal,
      hasVerticalMerges: hasVertical,
      totalPossibleMerges: totalMerges,
      fillPercentage: ((grid.tiles.length / (grid.size * grid.size)) * 100),
    );
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Counts total number of possible merges in grid
  int countPossibleMerges(GridEntity grid) {
    int count = 0;
    final size = grid.size;

    // Count horizontal merges
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size - 1; col++) {
        final current = grid.getTileAt(PositionEntity(row: row, col: col));
        final next = grid.getTileAt(PositionEntity(row: row, col: col + 1));

        if (canMergeTiles(current?.value, next?.value)) {
          count++;
        }
      }
    }

    // Count vertical merges
    for (int col = 0; col < size; col++) {
      for (int row = 0; row < size - 1; row++) {
        final current = grid.getTileAt(PositionEntity(row: row, col: col));
        final next = grid.getTileAt(PositionEntity(row: row + 1, col: col));

        if (canMergeTiles(current?.value, next?.value)) {
          count++;
        }
      }
    }

    return count;
  }

  /// Gets merge opportunities grouped by direction
  MergeOpportunities getMergeOpportunities(GridEntity grid) {
    final horizontal = <PositionEntity>[];
    final vertical = <PositionEntity>[];
    final size = grid.size;

    // Find horizontal merge positions
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size - 1; col++) {
        final pos = PositionEntity(row: row, col: col);
        final current = grid.getTileAt(pos);
        final next = grid.getTileAt(PositionEntity(row: row, col: col + 1));

        if (canMergeTiles(current?.value, next?.value)) {
          horizontal.add(pos);
        }
      }
    }

    // Find vertical merge positions
    for (int col = 0; col < size; col++) {
      for (int row = 0; row < size - 1; row++) {
        final pos = PositionEntity(row: row, col: col);
        final current = grid.getTileAt(pos);
        final next = grid.getTileAt(PositionEntity(row: row + 1, col: col));

        if (canMergeTiles(current?.value, next?.value)) {
          vertical.add(pos);
        }
      }
    }

    return MergeOpportunities(
      horizontalPositions: horizontal,
      verticalPositions: vertical,
      totalCount: horizontal.length + vertical.length,
    );
  }

  /// Gets statistics about grid density and state
  GridDensityStats getDensityStats(GridEntity grid) {
    final totalCells = grid.size * grid.size;
    final occupiedCells = grid.tiles.length;
    final emptyCount = totalCells - occupiedCells;
    final possibleMerges = countPossibleMerges(grid);

    return GridDensityStats(
      totalCells: totalCells,
      occupiedCells: occupiedCells,
      emptyCells: emptyCount,
      fillPercentage: (occupiedCells / totalCells * 100),
      possibleMerges: possibleMerges,
      isFullyOccupied: emptyCount == 0,
      isGameOver: isGameOver(grid),
    );
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates if grid is in valid state for game over check
  bool isValidGridState(GridEntity grid) {
    // Grid size should be positive
    if (grid.size <= 0) {
      return false;
    }

    // Tile count should not exceed grid capacity
    final maxTiles = grid.size * grid.size;
    if (grid.tiles.length > maxTiles) {
      return false;
    }

    // All tiles should be within grid bounds
    for (final tile in grid.tiles) {
      if (!isWithinBounds(tile.position, grid.size)) {
        return false;
      }
    }

    return true;
  }

  /// Checks if position is within grid bounds
  bool isWithinBounds(PositionEntity position, int gridSize) {
    return position.row >= 0 &&
        position.row < gridSize &&
        position.col >= 0 &&
        position.col < gridSize;
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Detailed information about game state
class GameStateInfo {
  final bool isGameOver;
  final bool hasEmptyPositions;
  final int emptyPositionCount;
  final bool hasHorizontalMerges;
  final bool hasVerticalMerges;
  final int totalPossibleMerges;
  final double fillPercentage;

  const GameStateInfo({
    required this.isGameOver,
    required this.hasEmptyPositions,
    required this.emptyPositionCount,
    required this.hasHorizontalMerges,
    required this.hasVerticalMerges,
    required this.totalPossibleMerges,
    required this.fillPercentage,
  });

  /// Quick check if any moves are available
  bool get hasAvailableMoves =>
      hasEmptyPositions || hasHorizontalMerges || hasVerticalMerges;
}

/// Merge opportunities found in grid
class MergeOpportunities {
  final List<PositionEntity> horizontalPositions;
  final List<PositionEntity> verticalPositions;
  final int totalCount;

  const MergeOpportunities({
    required this.horizontalPositions,
    required this.verticalPositions,
    required this.totalCount,
  });

  /// Gets all merge positions combined
  List<PositionEntity> get allPositions =>
      [...horizontalPositions, ...verticalPositions];

  /// Checks if specific position has merge opportunity
  bool hasOpportunityAt(PositionEntity position) {
    return horizontalPositions.contains(position) ||
        verticalPositions.contains(position);
  }
}

/// Statistics about grid density and occupation
class GridDensityStats {
  final int totalCells;
  final int occupiedCells;
  final int emptyCells;
  final double fillPercentage;
  final int possibleMerges;
  final bool isFullyOccupied;
  final bool isGameOver;

  const GridDensityStats({
    required this.totalCells,
    required this.occupiedCells,
    required this.emptyCells,
    required this.fillPercentage,
    required this.possibleMerges,
    required this.isFullyOccupied,
    required this.isGameOver,
  });

  /// Gets remaining capacity percentage
  double get remainingCapacity => 100 - fillPercentage;

  /// Checks if grid is nearly full (>80% filled)
  bool get isNearlyFull => fillPercentage >= 80;
}
