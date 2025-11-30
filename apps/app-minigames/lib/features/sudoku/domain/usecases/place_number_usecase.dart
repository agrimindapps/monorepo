import 'package:core/core.dart';
import '../entities/sudoku_grid_entity.dart';
import 'validate_move_usecase.dart';
import 'update_conflicts_usecase.dart';

/// Use case for placing a number on the grid
///
/// Steps:
/// 1. Validate the move
/// 2. Update cell with new value
/// 3. Update conflicts across grid
/// 4. Return updated grid
class PlaceNumberUseCase {
  final ValidateMoveUseCase _validateMoveUseCase;
  final UpdateConflictsUseCase _updateConflictsUseCase;

  PlaceNumberUseCase(
    this._validateMoveUseCase,
    this._updateConflictsUseCase,
  );

  /// Place number on grid
  /// Returns Either<Failure, SudokuGridEntity>
  Either<Failure, SudokuGridEntity> call({
    required SudokuGridEntity grid,
    required int row,
    required int col,
    required int value,
  }) {
    try {
      // Validate move first
      final validationResult = _validateMoveUseCase(
        grid: grid,
        row: row,
        col: col,
        value: value,
      );

      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => const Left(UnexpectedFailure('Unexpected validation result')),
        );
      }

      // Get cell and update value
      final cell = grid.getCell(row, col);
      final updatedCell = cell.placeValue(value);

      // Update grid with new cell
      var updatedGrid = grid.updateCell(updatedCell);

      // Update conflicts
      updatedGrid = _updateConflictsUseCase.call(updatedGrid);

      return Right(updatedGrid);
    } catch (e) {
      return Left(UnexpectedFailure('Error placing number: $e'));
    }
  }
}
