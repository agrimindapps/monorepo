import 'package:core/core.dart';
import '../entities/sudoku_grid_entity.dart';
import '../services/grid_validation_service.dart';

/// Use case for validating if a move is legal
///
/// Checks:
/// - Cell is editable (not a fixed clue)
/// - Number is valid (1-9)
/// - No conflicts in row/column/block
class ValidateMoveUseCase {
  final GridValidationService _validationService;

  ValidateMoveUseCase(this._validationService);

  /// Validate a move
  /// Returns Either<Failure, bool>
  /// - Right(true) if move is valid
  /// - Left(ValidationFailure) if move is invalid
  Either<Failure, bool> call({
    required SudokuGridEntity grid,
    required int row,
    required int col,
    required int value,
  }) {
    try {
      // Validate position
      if (row < 0 || row >= 9 || col < 0 || col >= 9) {
        return const Left(
          ValidationFailure('Position out of bounds (must be 0-8)'),
        );
      }

      // Validate value
      if (value < 1 || value > 9) {
        return const Left(ValidationFailure('Value must be between 1 and 9'));
      }

      // Check if cell is editable
      final cell = grid.getCell(row, col);
      if (cell.isFixed) {
        return const Left(ValidationFailure('Cannot modify a fixed cell'));
      }

      // Check if placement is valid (no conflicts)
      final isValid = _validationService.isValidPlacement(
        grid: grid,
        row: row,
        col: col,
        value: value,
      );

      if (!isValid) {
        return const Left(
          ValidationFailure('This number conflicts with existing numbers'),
        );
      }

      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure('Error validating move: $e'));
    }
  }
}
