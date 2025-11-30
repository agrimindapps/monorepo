import 'package:core/core.dart';
import '../entities/sudoku_grid_entity.dart';

/// Use case for checking if puzzle is complete and valid
///
/// Completion criteria:
/// 1. All cells are filled (no empty cells)
/// 2. No conflicts exist (all rules satisfied)
class CheckCompletionUseCase {
  /// Check if puzzle is complete
  /// Returns Either<Failure, bool>
  /// - Right(true) if puzzle is solved
  /// - Right(false) if puzzle is not complete
  /// - Left(Failure) on error
  Either<Failure, bool> call(SudokuGridEntity grid) {
    try {
      // Check if grid is complete (all cells filled)
      if (!grid.isComplete) {
        return const Right(false);
      }

      // Check if grid is valid (no conflicts)
      if (!grid.isValid) {
        return const Right(false);
      }

      // Puzzle is complete and valid
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure('Error checking completion: $e'));
    }
  }

  /// Get completion percentage
  Either<Failure, double> getProgress(SudokuGridEntity grid) {
    try {
      final filledCount = grid.filledCount;
      final progress = filledCount / 81.0;
      return Right(progress);
    } catch (e) {
      return Left(UnexpectedFailure('Error calculating progress: $e'));
    }
  }
}
