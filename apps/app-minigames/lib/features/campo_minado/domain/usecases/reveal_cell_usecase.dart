import 'dart:math';
import 'package:core/core.dart';
import '../entities/game_state.dart';
import '../entities/cell_data.dart';
import '../entities/enums.dart';

/// Use case for revealing a cell in the minefield
class RevealCellUseCase {
  const RevealCellUseCase();

  Future<Either<Failure, GameState>> call({
    required GameState currentState,
    required int row,
    required int col,
  }) async {
    // Validation
    if (row < 0 || row >= currentState.rows || col < 0 || col >= currentState.cols) {
      return const Left(ValidationFailure('Posição inválida'));
    }

    if (!currentState.canInteract) {
      return const Left(ValidationFailure('Jogo não está ativo'));
    }

    final cell = currentState.grid[row][col];

    if (cell.isFlagged || cell.isRevealed) {
      return Right(currentState);
    }

    // First click: place mines avoiding this cell
    GameState updatedState = currentState;
    if (currentState.isFirstClick) {
      updatedState = _placeMines(currentState, row, col);
      updatedState = updatedState.copyWith(
        status: GameStatus.playing,
        isFirstClick: false,
      );
    }

    // Reveal the cell
    final revealedCell = updatedState.grid[row][col].copyWith(
      status: CellStatus.revealed,
      isExploded: updatedState.grid[row][col].isMine,
    );

    final newGrid = _updateGrid(updatedState.grid, row, col, revealedCell);
    int newRevealedCount = updatedState.revealedCells + 1;

    updatedState = updatedState.copyWith(
      grid: newGrid,
      revealedCells: newRevealedCount,
    );

    // Check if mine was hit
    if (revealedCell.isMine) {
      return Right(_handleGameLost(updatedState));
    }

    // Auto-reveal empty neighbors (flood-fill)
    if (revealedCell.isEmpty) {
      updatedState = _autoRevealNeighbors(updatedState, row, col);
    }

    // Check win condition
    if (updatedState.revealedCells >= updatedState.config.safeCells) {
      return Right(_handleGameWon(updatedState));
    }

    return Right(updatedState);
  }

  /// Places mines randomly, avoiding the first clicked cell and its neighbors
  GameState _placeMines(GameState state, int excludeRow, int excludeCol) {
    final random = Random();
    final excludePositions = state.getNeighborPositions(excludeRow, excludeCol);
    excludePositions.add([excludeRow, excludeCol]);

    final newGrid = state.grid.map((row) => row.toList()).toList();
    int minesPlaced = 0;
    int attempts = 0;
    final maxAttempts = state.config.totalCells * 10;

    while (minesPlaced < state.config.mines && attempts < maxAttempts) {
      final row = random.nextInt(state.rows);
      final col = random.nextInt(state.cols);
      attempts++;

      // Skip if position should be excluded or already has mine
      if (excludePositions.any((pos) => pos[0] == row && pos[1] == col) ||
          newGrid[row][col].isMine) {
        continue;
      }

      newGrid[row][col] = newGrid[row][col].copyWith(isMine: true);
      minesPlaced++;
    }

    // Calculate neighbor counts
    final gridWithCounts = _calculateNeighborCounts(newGrid, state.config);

    return state.copyWith(grid: gridWithCounts);
  }

  /// Calculates neighbor mine counts for all cells
  List<List<CellData>> _calculateNeighborCounts(
    List<List<CellData>> grid,
    GameConfig config,
  ) {
    final newGrid = grid.map((row) => row.toList()).toList();

    for (int row = 0; row < config.rows; row++) {
      for (int col = 0; col < config.cols; col++) {
        if (!newGrid[row][col].isMine) {
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
                  newGrid[newRow][newCol].isMine) {
                count++;
              }
            }
          }

          newGrid[row][col] = newGrid[row][col].copyWith(neighborMines: count);
        }
      }
    }

    return newGrid;
  }

  /// Auto-reveals empty neighboring cells recursively (flood-fill)
  GameState _autoRevealNeighbors(GameState state, int row, int col) {
    final neighbors = state.getNeighborPositions(row, col);
    GameState currentState = state;

    for (final pos in neighbors) {
      final neighborRow = pos[0];
      final neighborCol = pos[1];
      final neighborCell = currentState.grid[neighborRow][neighborCol];

      if (!neighborCell.isRevealed &&
          !neighborCell.isFlagged &&
          !neighborCell.isMine) {
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

        // Recursively reveal if neighbor is also empty
        if (revealedNeighbor.isEmpty) {
          currentState = _autoRevealNeighbors(currentState, neighborRow, neighborCol);
        }
      }
    }

    return currentState;
  }

  /// Handles game lost state
  GameState _handleGameLost(GameState state) {
    // Reveal all mines
    final newGrid = state.grid.map((row) => row.toList()).toList();

    for (int row = 0; row < state.rows; row++) {
      for (int col = 0; col < state.cols; col++) {
        if (newGrid[row][col].isMine && !newGrid[row][col].isRevealed) {
          newGrid[row][col] = newGrid[row][col].copyWith(
            status: CellStatus.revealed,
          );
        }
      }
    }

    return state.copyWith(
      grid: newGrid,
      status: GameStatus.lost,
    );
  }

  /// Handles game won state
  GameState _handleGameWon(GameState state) {
    // Auto-flag remaining mines
    final newGrid = state.grid.map((row) => row.toList()).toList();
    int newFlaggedCount = state.flaggedCells;

    for (int row = 0; row < state.rows; row++) {
      for (int col = 0; col < state.cols; col++) {
        if (newGrid[row][col].isMine && !newGrid[row][col].isFlagged) {
          newGrid[row][col] = newGrid[row][col].copyWith(
            status: CellStatus.flagged,
          );
          newFlaggedCount++;
        }
      }
    }

    return state.copyWith(
      grid: newGrid,
      status: GameStatus.won,
      flaggedCells: newFlaggedCount,
    );
  }

  /// Updates a single cell in the grid
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
}
