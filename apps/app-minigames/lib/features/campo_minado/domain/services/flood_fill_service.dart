import 'package:injectable/injectable.dart';

import '../entities/cell_data.dart';
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Service responsible for flood-fill algorithm (auto-revealing empty cells)
/// Follows SRP by handling only cell revelation logic
@lazySingleton
class FloodFillService {
  /// Auto-reveals empty neighboring cells recursively
  GameState autoRevealNeighbors({
    required GameState state,
    required int row,
    required int col,
  }) {
    final neighbors = state.getNeighborPositions(row, col);
    GameState currentState = state;

    for (final pos in neighbors) {
      final neighborRow = pos[0];
      final neighborCol = pos[1];
      final neighborCell = currentState.grid[neighborRow][neighborCol];

      // Skip if already revealed, flagged, or is a mine
      if (neighborCell.isRevealed ||
          neighborCell.isFlagged ||
          neighborCell.isMine) {
        continue;
      }

      // Reveal the neighbor
      final revealedNeighbor = neighborCell.copyWith(
        status: CellStatus.revealed,
      );

      final newGrid = _updateGrid(
        currentState.grid,
        neighborRow,
        neighborCol,
        revealedNeighbor,
      );

      currentState = currentState.copyWith(
        grid: newGrid,
        revealedCells: currentState.revealedCells + 1,
      );

      // If neighbor is also empty, recursively reveal its neighbors
      if (revealedNeighbor.isEmpty) {
        currentState = autoRevealNeighbors(
          state: currentState,
          row: neighborRow,
          col: neighborCol,
        );
      }
    }

    return currentState;
  }

  /// Updates grid with new cell data
  List<List<CellData>> _updateGrid(
    List<List<CellData>> grid,
    int row,
    int col,
    CellData newCell,
  ) {
    final newGrid = grid.map((r) => r.toList()).toList();
    newGrid[row][col] = newCell;
    return newGrid;
  }

  /// Reveals a single cell
  GameState revealCell({
    required GameState state,
    required int row,
    required int col,
  }) {
    final cell = state.grid[row][col];

    if (cell.isRevealed || cell.isFlagged) {
      return state;
    }

    final revealedCell = cell.copyWith(
      status: CellStatus.revealed,
      isExploded: cell.isMine,
    );

    final newGrid = _updateGrid(state.grid, row, col, revealedCell);

    return state.copyWith(
      grid: newGrid,
      revealedCells: state.revealedCells + 1,
    );
  }

  /// Reveals all cells (used for game over)
  GameState revealAllCells(GameState state) {
    final newGrid = state.grid.map((row) {
      return row.map((cell) {
        if (!cell.isRevealed) {
          return cell.copyWith(status: CellStatus.revealed);
        }
        return cell;
      }).toList();
    }).toList();

    return state.copyWith(grid: newGrid);
  }

  /// Reveals all mines (used for game lost)
  GameState revealAllMines(GameState state) {
    final newGrid = state.grid.map((row) {
      return row.map((cell) {
        if (cell.isMine && !cell.isRevealed) {
          return cell.copyWith(status: CellStatus.revealed);
        }
        return cell;
      }).toList();
    }).toList();

    return state.copyWith(grid: newGrid);
  }

  /// Counts cells that would be revealed in flood fill
  int countFloodFillCells({
    required GameState state,
    required int row,
    required int col,
  }) {
    final visited = <String>{};
    return _countFloodFillRecursive(state, row, col, visited);
  }

  int _countFloodFillRecursive(
    GameState state,
    int row,
    int col,
    Set<String> visited,
  ) {
    final key = '$row,$col';

    if (visited.contains(key)) return 0;

    visited.add(key);

    final cell = state.grid[row][col];

    if (cell.isRevealed || cell.isFlagged || cell.isMine) {
      return 0;
    }

    int count = 1;

    if (cell.isEmpty) {
      final neighbors = state.getNeighborPositions(row, col);

      for (final pos in neighbors) {
        count += _countFloodFillRecursive(state, pos[0], pos[1], visited);
      }
    }

    return count;
  }

  /// Gets all cells that would be revealed in flood fill
  List<List<int>> getFloodFillPositions({
    required GameState state,
    required int row,
    required int col,
  }) {
    final visited = <String>{};
    final positions = <List<int>>[];

    _collectFloodFillPositions(state, row, col, visited, positions);

    return positions;
  }

  void _collectFloodFillPositions(
    GameState state,
    int row,
    int col,
    Set<String> visited,
    List<List<int>> positions,
  ) {
    final key = '$row,$col';

    if (visited.contains(key)) return;

    visited.add(key);

    final cell = state.grid[row][col];

    if (cell.isRevealed || cell.isFlagged || cell.isMine) {
      return;
    }

    positions.add([row, col]);

    if (cell.isEmpty) {
      final neighbors = state.getNeighborPositions(row, col);

      for (final pos in neighbors) {
        _collectFloodFillPositions(state, pos[0], pos[1], visited, positions);
      }
    }
  }

  /// Validates flood fill operation
  FloodFillValidation validateFloodFill({
    required GameState state,
    required int row,
    required int col,
  }) {
    if (row < 0 || row >= state.rows || col < 0 || col >= state.cols) {
      return FloodFillValidation(
        isValid: false,
        errorMessage: 'Position out of bounds',
      );
    }

    final cell = state.grid[row][col];

    if (cell.isMine) {
      return FloodFillValidation(
        isValid: false,
        errorMessage: 'Cannot flood fill from mine cell',
      );
    }

    if (cell.isRevealed) {
      return FloodFillValidation(
        isValid: false,
        errorMessage: 'Cell already revealed',
      );
    }

    return FloodFillValidation(isValid: true);
  }
}

// Models

class FloodFillValidation {
  final bool isValid;
  final String? errorMessage;

  FloodFillValidation({
    required this.isValid,
    this.errorMessage,
  });
}
