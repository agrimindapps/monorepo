import 'package:core/core.dart';
import '../entities/game_state.dart';
import '../entities/cell_data.dart';
import '../entities/enums.dart';

/// Use case for toggling flag on a cell
class ToggleFlagUseCase {
  const ToggleFlagUseCase();

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

    if (cell.isRevealed) {
      return Right(currentState);
    }

    // Toggle flag state: hidden -> flagged -> questioned -> hidden
    CellStatus newStatus;
    int flaggedDelta = 0;

    if (cell.isFlagged) {
      newStatus = CellStatus.questioned;
      flaggedDelta = -1;
    } else if (cell.isQuestioned) {
      newStatus = CellStatus.hidden;
      flaggedDelta = 0;
    } else {
      newStatus = CellStatus.flagged;
      flaggedDelta = 1;
    }

    final updatedCell = cell.copyWith(status: newStatus);
    final newGrid = _updateGrid(currentState.grid, row, col, updatedCell);

    return Right(
      currentState.copyWith(
        grid: newGrid,
        flaggedCells: currentState.flaggedCells + flaggedDelta,
      ),
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
