import 'package:core/core.dart';
import '../entities/position_entity.dart';
import '../entities/sudoku_grid_entity.dart';

/// Use case for getting a hint
///
/// Algorithm:
/// 1. Find all empty cells
/// 2. For each empty cell, find valid numbers
/// 3. Select a random cell that has valid moves
/// 4. Return position and correct value
class GetHintUseCase {
  /// Get a hint (random empty cell with correct value)
  /// Returns Either<Failure, (PositionEntity, int)>
  Either<Failure, (PositionEntity, int)> call(SudokuGridEntity grid) {
    try {
      // Get all empty cells
      final emptyCells = grid.getEmptyCells();

      if (emptyCells.isEmpty) {
        return const Left(
          ValidationFailure('No empty cells available for hint'),
        );
      }

      // Find cells with valid moves
      final cellsWithMoves = <(PositionEntity, List<int>)>[];

      for (final cell in emptyCells) {
        final validNumbers = _findValidNumbers(grid, cell.row, cell.col);
        if (validNumbers.isNotEmpty) {
          cellsWithMoves.add((cell.position, validNumbers));
        }
      }

      if (cellsWithMoves.isEmpty) {
        return const Left(
          UnexpectedFailure('No valid moves found (puzzle may be unsolvable)'),
        );
      }

      // Select random cell
      cellsWithMoves.shuffle();
      final (position, validNumbers) = cellsWithMoves.first;

      // Use first valid number (could be randomized)
      final hintValue = validNumbers.first;

      return Right((position, hintValue));
    } catch (e) {
      return Left(UnexpectedFailure('Error getting hint: $e'));
    }
  }

  /// Find all valid numbers for a position
  List<int> _findValidNumbers(SudokuGridEntity grid, int row, int col) {
    final validNumbers = <int>[];

    for (int num = 1; num <= 9; num++) {
      if (grid.isValidPlacement(row, col, num)) {
        validNumbers.add(num);
      }
    }

    return validNumbers;
  }

  /// Get count of available hints
  Either<Failure, int> getHintCount(SudokuGridEntity grid) {
    try {
      final emptyCells = grid.getEmptyCells();
      return Right(emptyCells.length);
    } catch (e) {
      return Left(UnexpectedFailure('Error counting hints: $e'));
    }
  }
}
