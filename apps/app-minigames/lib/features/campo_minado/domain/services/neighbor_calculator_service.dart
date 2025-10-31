import 'package:injectable/injectable.dart';

import '../entities/cell_data.dart';
import '../entities/enums.dart';

/// Service responsible for calculating neighbor mine counts
/// Follows SRP by handling only neighbor count calculations
@lazySingleton
class NeighborCalculatorService {
  /// Calculates neighbor mine counts for all cells in the grid
  List<List<CellData>> calculateNeighborCounts({
    required List<List<CellData>> grid,
    required GameConfig config,
  }) {
    final newGrid = grid.map((row) => row.toList()).toList();

    for (int row = 0; row < config.rows; row++) {
      for (int col = 0; col < config.cols; col++) {
        if (!newGrid[row][col].isMine) {
          final count = countNeighborMines(
            grid: newGrid,
            row: row,
            col: col,
            config: config,
          );

          newGrid[row][col] = newGrid[row][col].copyWith(neighborMines: count);
        }
      }
    }

    return newGrid;
  }

  /// Counts mines in neighboring cells
  int countNeighborMines({
    required List<List<CellData>> grid,
    required int row,
    required int col,
    required GameConfig config,
  }) {
    int count = 0;

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        final newRow = row + dr;
        final newCol = col + dc;

        if (newRow >= 0 &&
            newRow < config.rows &&
            newCol >= 0 &&
            newCol < config.cols &&
            grid[newRow][newCol].isMine) {
          count++;
        }
      }
    }

    return count;
  }

  /// Gets all neighbor positions for a cell
  List<List<int>> getNeighborPositions({
    required int row,
    required int col,
    required int maxRows,
    required int maxCols,
  }) {
    final neighbors = <List<int>>[];

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        final newRow = row + dr;
        final newCol = col + dc;

        if (newRow >= 0 &&
            newRow < maxRows &&
            newCol >= 0 &&
            newCol < maxCols) {
          neighbors.add([newRow, newCol]);
        }
      }
    }

    return neighbors;
  }

  /// Gets safe neighbor positions (no mines)
  List<List<int>> getSafeNeighborPositions({
    required List<List<CellData>> grid,
    required int row,
    required int col,
    required int maxRows,
    required int maxCols,
  }) {
    final neighbors = getNeighborPositions(
      row: row,
      col: col,
      maxRows: maxRows,
      maxCols: maxCols,
    );

    return neighbors.where((pos) => !grid[pos[0]][pos[1]].isMine).toList();
  }

  /// Gets unrevealed neighbor positions
  List<List<int>> getUnrevealedNeighborPositions({
    required List<List<CellData>> grid,
    required int row,
    required int col,
    required int maxRows,
    required int maxCols,
  }) {
    final neighbors = getNeighborPositions(
      row: row,
      col: col,
      maxRows: maxRows,
      maxCols: maxCols,
    );

    return neighbors.where((pos) => !grid[pos[0]][pos[1]].isRevealed).toList();
  }

  /// Gets flagged neighbor positions
  List<List<int>> getFlaggedNeighborPositions({
    required List<List<CellData>> grid,
    required int row,
    required int col,
    required int maxRows,
    required int maxCols,
  }) {
    final neighbors = getNeighborPositions(
      row: row,
      col: col,
      maxRows: maxRows,
      maxCols: maxCols,
    );

    return neighbors.where((pos) => grid[pos[0]][pos[1]].isFlagged).toList();
  }

  /// Counts flagged neighbors
  int countFlaggedNeighbors({
    required List<List<CellData>> grid,
    required int row,
    required int col,
    required int maxRows,
    required int maxCols,
  }) {
    return getFlaggedNeighborPositions(
      grid: grid,
      row: row,
      col: col,
      maxRows: maxRows,
      maxCols: maxCols,
    ).length;
  }

  /// Validates neighbor count calculation
  bool validateNeighborCounts({
    required List<List<CellData>> grid,
    required GameConfig config,
  }) {
    for (int row = 0; row < config.rows; row++) {
      for (int col = 0; col < config.cols; col++) {
        final cell = grid[row][col];

        if (!cell.isMine) {
          final expectedCount = countNeighborMines(
            grid: grid,
            row: row,
            col: col,
            config: config,
          );

          if (cell.neighborMines != expectedCount) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// Gets grid statistics
  GridNeighborStatistics getGridStatistics({
    required List<List<CellData>> grid,
    required GameConfig config,
  }) {
    int cellsWithZeroNeighbors = 0;
    int cellsWithMaxNeighbors = 0;
    final neighborCounts = <int, int>{};

    for (int row = 0; row < config.rows; row++) {
      for (int col = 0; col < config.cols; col++) {
        final cell = grid[row][col];

        if (!cell.isMine) {
          final count = cell.neighborMines;

          neighborCounts[count] = (neighborCounts[count] ?? 0) + 1;

          if (count == 0) cellsWithZeroNeighbors++;
          if (count == 8) cellsWithMaxNeighbors++;
        }
      }
    }

    return GridNeighborStatistics(
      cellsWithZeroNeighbors: cellsWithZeroNeighbors,
      cellsWithMaxNeighbors: cellsWithMaxNeighbors,
      neighborCountDistribution: neighborCounts,
    );
  }
}

// Models

class GridNeighborStatistics {
  final int cellsWithZeroNeighbors;
  final int cellsWithMaxNeighbors;
  final Map<int, int> neighborCountDistribution;

  GridNeighborStatistics({
    required this.cellsWithZeroNeighbors,
    required this.cellsWithMaxNeighbors,
    required this.neighborCountDistribution,
  });
}
