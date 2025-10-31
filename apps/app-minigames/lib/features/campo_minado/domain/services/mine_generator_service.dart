import 'dart:math';
import 'package:injectable/injectable.dart';

import '../entities/cell_data.dart';
import '../entities/enums.dart';

/// Service responsible for mine placement logic
/// Follows SRP by handling only mine generation operations
@lazySingleton
class MineGeneratorService {
  final Random _random = Random();

  /// Places mines randomly on the grid, avoiding specified positions
  List<List<CellData>> placeMines({
    required List<List<CellData>> grid,
    required GameConfig config,
    required List<List<int>> excludePositions,
  }) {
    final newGrid = grid.map((row) => row.toList()).toList();
    int minesPlaced = 0;
    int attempts = 0;
    final maxAttempts = config.totalCells * 10;

    while (minesPlaced < config.mines && attempts < maxAttempts) {
      final row = _random.nextInt(config.rows);
      final col = _random.nextInt(config.cols);
      attempts++;

      // Skip if position should be excluded or already has mine
      if (_isExcludedPosition(row, col, excludePositions) ||
          newGrid[row][col].isMine) {
        continue;
      }

      newGrid[row][col] = newGrid[row][col].copyWith(isMine: true);
      minesPlaced++;
    }

    return newGrid;
  }

  /// Places mines for first click (avoiding clicked cell and neighbors)
  List<List<CellData>> placeMinesForFirstClick({
    required List<List<CellData>> grid,
    required GameConfig config,
    required int excludeRow,
    required int excludeCol,
  }) {
    final excludePositions = _getNeighborPositions(
      excludeRow,
      excludeCol,
      config.rows,
      config.cols,
    );
    excludePositions.add([excludeRow, excludeCol]);

    return placeMines(
      grid: grid,
      config: config,
      excludePositions: excludePositions,
    );
  }

  /// Checks if position should be excluded from mine placement
  bool _isExcludedPosition(
    int row,
    int col,
    List<List<int>> excludePositions,
  ) {
    return excludePositions.any((pos) => pos[0] == row && pos[1] == col);
  }

  /// Gets neighbor positions for a cell
  List<List<int>> _getNeighborPositions(
    int row,
    int col,
    int maxRows,
    int maxCols,
  ) {
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

  /// Validates mine placement
  MineValidation validateMinePlacement({
    required List<List<CellData>> grid,
    required GameConfig config,
  }) {
    int actualMines = 0;

    for (final row in grid) {
      for (final cell in row) {
        if (cell.isMine) actualMines++;
      }
    }

    if (actualMines != config.mines) {
      return MineValidation(
        isValid: false,
        errorMessage:
            'Mine count mismatch: expected ${config.mines}, got $actualMines',
      );
    }

    return MineValidation(isValid: true);
  }

  /// Gets mine statistics
  MineStatistics getMineStatistics(List<List<CellData>> grid) {
    int totalMines = 0;
    final minePositions = <List<int>>[];

    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        if (grid[row][col].isMine) {
          totalMines++;
          minePositions.add([row, col]);
        }
      }
    }

    return MineStatistics(
      totalMines: totalMines,
      minePositions: minePositions,
    );
  }

  /// Creates a test grid with specific mine positions
  List<List<CellData>> createTestGrid({
    required int rows,
    required int cols,
    required List<List<int>> minePositions,
  }) {
    final grid = List.generate(
      rows,
      (row) => List.generate(
        cols,
        (col) => CellData.initial(row: row, col: col),
      ),
    );

    for (final pos in minePositions) {
      final row = pos[0];
      final col = pos[1];

      if (row >= 0 && row < rows && col >= 0 && col < cols) {
        grid[row][col] = grid[row][col].copyWith(isMine: true);
      }
    }

    return grid;
  }
}

// Models

class MineValidation {
  final bool isValid;
  final String? errorMessage;

  MineValidation({
    required this.isValid,
    this.errorMessage,
  });
}

class MineStatistics {
  final int totalMines;
  final List<List<int>> minePositions;

  MineStatistics({
    required this.totalMines,
    required this.minePositions,
  });
}
