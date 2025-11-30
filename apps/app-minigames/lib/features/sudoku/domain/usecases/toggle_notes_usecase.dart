import 'package:core/core.dart';
import '../entities/sudoku_grid_entity.dart';

/// Use case for toggling notes (pencil marks) on a cell
///
/// Notes can only be added to:
/// - Empty cells
/// - Editable cells (not fixed clues)
class ToggleNotesUseCase {
  /// Toggle a note on a cell
  /// Returns Either<Failure, SudokuGridEntity>
  Either<Failure, SudokuGridEntity> call({
    required SudokuGridEntity grid,
    required int row,
    required int col,
    required int note,
  }) {
    try {
      // Validate position
      if (row < 0 || row >= 9 || col < 0 || col >= 9) {
        return const Left(
          ValidationFailure('Position out of bounds (must be 0-8)'),
        );
      }

      // Validate note value
      if (note < 1 || note > 9) {
        return const Left(
          ValidationFailure('Note must be between 1 and 9'),
        );
      }

      // Get cell
      final cell = grid.getCell(row, col);

      // Check if cell is editable
      if (cell.isFixed) {
        return const Left(
          ValidationFailure('Cannot add notes to fixed cells'),
        );
      }

      // Check if cell is empty
      if (!cell.isEmpty) {
        return const Left(
          ValidationFailure('Cannot add notes to filled cells'),
        );
      }

      // Toggle note
      final updatedCell = cell.toggleNote(note);

      // Update grid
      final updatedGrid = grid.updateCell(updatedCell);

      return Right(updatedGrid);
    } catch (e) {
      return Left(UnexpectedFailure('Error toggling notes: $e'));
    }
  }

  /// Clear all notes from a cell
  Either<Failure, SudokuGridEntity> clearNotes({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    try {
      // Validate position
      if (row < 0 || row >= 9 || col < 0 || col >= 9) {
        return const Left(
          ValidationFailure('Position out of bounds (must be 0-8)'),
        );
      }

      // Get cell and clear notes
      final cell = grid.getCell(row, col);
      final updatedCell = cell.clearNotes();

      // Update grid
      final updatedGrid = grid.updateCell(updatedCell);

      return Right(updatedGrid);
    } catch (e) {
      return Left(UnexpectedFailure('Error clearing notes: $e'));
    }
  }
}
