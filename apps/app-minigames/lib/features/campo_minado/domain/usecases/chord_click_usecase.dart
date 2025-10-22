import 'package:core/core.dart';
import '../entities/game_state.dart';
import 'reveal_cell_usecase.dart';

/// Use case for chord clicking (revealing neighbors when flag count matches)
class ChordClickUseCase {
  final RevealCellUseCase _revealCellUseCase;

  const ChordClickUseCase(this._revealCellUseCase);

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

    if (!cell.isRevealed || cell.neighborMines == 0) {
      return Right(currentState);
    }

    final neighbors = currentState.getNeighborPositions(row, col);
    int flaggedNeighbors = 0;

    // Count flagged neighbors
    for (final pos in neighbors) {
      if (currentState.grid[pos[0]][pos[1]].isFlagged) {
        flaggedNeighbors++;
      }
    }

    // If flagged count matches mine count, reveal unflagged neighbors
    if (flaggedNeighbors == cell.neighborMines) {
      GameState updatedState = currentState;

      for (final pos in neighbors) {
        final neighborRow = pos[0];
        final neighborCol = pos[1];
        final neighbor = updatedState.grid[neighborRow][neighborCol];

        if (!neighbor.isRevealed && !neighbor.isFlagged) {
          final result = await _revealCellUseCase(
            currentState: updatedState,
            row: neighborRow,
            col: neighborCol,
          );

          result.fold(
            (failure) => null, // Continue revealing others
            (newState) => updatedState = newState,
          );
        }
      }

      return Right(updatedState);
    }

    return Right(currentState);
  }
}
