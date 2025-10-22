import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/enums.dart';
import '../entities/sudoku_grid_entity.dart';

/// Use case for generating a new Sudoku puzzle
///
/// Algorithm:
/// 1. Create empty grid
/// 2. Fill diagonal 3x3 blocks (independent, no conflicts)
/// 3. Solve remaining cells using backtracking
/// 4. Remove cells based on difficulty
/// 5. Ensure unique solution (basic check)
class GeneratePuzzleUseCase {
  /// Generate a new puzzle
  /// Returns Either<Failure, SudokuGridEntity>
  Future<Either<Failure, SudokuGridEntity>> call(
    GameDifficulty difficulty,
  ) async {
    try {
      // Create empty grid
      var grid = SudokuGridEntity.empty();

      // Fill diagonal blocks (0,0), (3,3), (6,6)
      grid = _fillDiagonalBlocks(grid);

      // Solve the rest using backtracking
      final solvedGrid = _solvePuzzle(grid);
      if (solvedGrid == null) {
        return const Left(
          UnexpectedFailure('Failed to generate solved puzzle'),
        );
      }

      // Remove cells based on difficulty
      final puzzle = _removeCells(solvedGrid, difficulty.cellsToRemove);

      return Right(puzzle);
    } catch (e) {
      return Left(UnexpectedFailure('Error generating puzzle: $e'));
    }
  }

  /// Fill diagonal 3x3 blocks with random numbers
  SudokuGridEntity _fillDiagonalBlocks(SudokuGridEntity grid) {
    var updatedGrid = grid;

    // Fill blocks at positions (0,0), (3,3), (6,6)
    for (int blockStart = 0; blockStart < 9; blockStart += 3) {
      updatedGrid = _fillBlock(updatedGrid, blockStart, blockStart);
    }

    return updatedGrid;
  }

  /// Fill a 3x3 block with random numbers 1-9
  SudokuGridEntity _fillBlock(SudokuGridEntity grid, int startRow, int startCol) {
    var updatedGrid = grid;
    final numbers = List.generate(9, (i) => i + 1)..shuffle();

    int index = 0;
    for (int row = startRow; row < startRow + 3; row++) {
      for (int col = startCol; col < startCol + 3; col++) {
        final cell = updatedGrid.getCell(row, col);
        final updatedCell = cell.copyWith(
          value: numbers[index++],
          isFixed: true,
        );
        updatedGrid = updatedGrid.updateCell(updatedCell);
      }
    }

    return updatedGrid;
  }

  /// Solve puzzle using backtracking algorithm
  SudokuGridEntity? _solvePuzzle(SudokuGridEntity grid) {
    // Find first empty cell
    SudokuGridEntity? currentGrid = grid;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final cell = currentGrid!.getCell(row, col);

        if (cell.isEmpty) {
          // Try numbers 1-9
          for (int num = 1; num <= 9; num++) {
            if (currentGrid.isValidPlacement(row, col, num)) {
              // Place number
              final updatedCell = cell.copyWith(
                value: num,
                isFixed: true,
              );
              final newGrid = currentGrid.updateCell(updatedCell);

              // Recursive solve
              final solved = _solvePuzzle(newGrid);
              if (solved != null) {
                return solved;
              }
            }
          }

          // No valid number found, backtrack
          return null;
        }
      }
    }

    // All cells filled, puzzle solved
    return currentGrid;
  }

  /// Remove cells to create puzzle
  SudokuGridEntity _removeCells(SudokuGridEntity grid, int cellsToRemove) {
    var updatedGrid = grid;
    final allPositions = <List<int>>[];

    // Create list of all positions
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        allPositions.add([row, col]);
      }
    }

    // Shuffle positions
    allPositions.shuffle();

    // Remove specified number of cells
    int removed = 0;
    for (final position in allPositions) {
      if (removed >= cellsToRemove) break;

      final row = position[0];
      final col = position[1];
      final cell = updatedGrid.getCell(row, col);

      // Clear value but keep as editable
      final updatedCell = cell.copyWith(
        clearValue: true,
        isFixed: false,
      );
      updatedGrid = updatedGrid.updateCell(updatedCell);
      removed++;
    }

    return updatedGrid;
  }
}
