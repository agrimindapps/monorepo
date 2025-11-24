import 'dart:math';

import 'package:flutter/foundation.dart';

import '../entities/enums.dart';
import '../entities/sudoku_grid_entity.dart';

/// Service responsible for Sudoku puzzle generation
///
/// Handles:
/// - Grid creation and initialization
/// - Diagonal block filling (independent blocks)
/// - Backtracking solver algorithm
/// - Cell removal based on difficulty
/// - Puzzle uniqueness validation
class PuzzleGeneratorService {
  final Random _random;

  PuzzleGeneratorService() : _random = Random();

  // For testing purposes
  @visibleForTesting
  PuzzleGeneratorService.withRandom(Random random) : _random = random;

  // ============================================================================
  // Main Generation
  // ============================================================================

  /// Generates a complete solved grid
  SudokuGridEntity? generateSolvedGrid() {
    // Create empty grid
    var grid = SudokuGridEntity.empty();

    // Fill diagonal blocks (independent, no conflicts)
    grid = fillDiagonalBlocks(grid);

    // Solve remaining cells
    return solvePuzzle(grid);
  }

  /// Generates a puzzle by removing cells from solved grid
  SudokuGridEntity? generatePuzzle({
    required GameDifficulty difficulty,
  }) {
    // Generate solved grid
    final solvedGrid = generateSolvedGrid();
    if (solvedGrid == null) return null;

    // Remove cells based on difficulty
    return removeCells(
      grid: solvedGrid,
      cellsToRemove: difficulty.cellsToRemove,
    );
  }

  // ============================================================================
  // Diagonal Block Filling
  // ============================================================================

  /// Fills the three diagonal 3x3 blocks (0,0), (3,3), (6,6)
  /// These blocks are independent and can be filled without conflicts
  SudokuGridEntity fillDiagonalBlocks(SudokuGridEntity grid) {
    var updatedGrid = grid;

    // Fill blocks at positions (0,0), (3,3), (6,6)
    for (int blockStart = 0; blockStart < 9; blockStart += 3) {
      updatedGrid = fillBlock(
        grid: updatedGrid,
        startRow: blockStart,
        startCol: blockStart,
      );
    }

    return updatedGrid;
  }

  /// Fills a 3x3 block with shuffled numbers 1-9
  SudokuGridEntity fillBlock({
    required SudokuGridEntity grid,
    required int startRow,
    required int startCol,
  }) {
    var updatedGrid = grid;

    // Generate shuffled numbers 1-9
    final numbers = getShuffledNumbers();

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

  /// Gets shuffled list of numbers 1-9
  List<int> getShuffledNumbers() {
    final numbers = List.generate(9, (i) => i + 1);
    numbers.shuffle(_random);
    return numbers;
  }

  // ============================================================================
  // Backtracking Solver
  // ============================================================================

  /// Solves puzzle using backtracking algorithm
  SudokuGridEntity? solvePuzzle(SudokuGridEntity grid) {
    // Find first empty cell
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final cell = grid.getCell(row, col);

        if (cell.isEmpty) {
          // Try numbers 1-9
          for (int num = 1; num <= 9; num++) {
            if (grid.isValidPlacement(row, col, num)) {
              // Place number
              final updatedCell = cell.copyWith(
                value: num,
                isFixed: true,
              );
              final newGrid = grid.updateCell(updatedCell);

              // Recursive solve
              final solved = solvePuzzle(newGrid);
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
    return grid;
  }

  /// Solves puzzle with specific number order (for testing)
  SudokuGridEntity? solvePuzzleWithOrder(
    SudokuGridEntity grid,
    List<int> numberOrder,
  ) {
    // Find first empty cell
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final cell = grid.getCell(row, col);

        if (cell.isEmpty) {
          // Try numbers in specified order
          for (int num in numberOrder) {
            if (grid.isValidPlacement(row, col, num)) {
              // Place number
              final updatedCell = cell.copyWith(
                value: num,
                isFixed: true,
              );
              final newGrid = grid.updateCell(updatedCell);

              // Recursive solve
              final solved = solvePuzzleWithOrder(newGrid, numberOrder);
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
    return grid;
  }

  // ============================================================================
  // Cell Removal
  // ============================================================================

  /// Removes cells from solved grid to create puzzle
  SudokuGridEntity removeCells({
    required SudokuGridEntity grid,
    required int cellsToRemove,
  }) {
    var updatedGrid = grid;

    // Get all positions
    final allPositions = getAllPositions();

    // Shuffle positions
    shufflePositions(allPositions);

    // Remove specified number of cells
    int removed = 0;
    for (final position in allPositions) {
      if (removed >= cellsToRemove) break;

      final row = position[0];
      final col = position[1];
      final cell = updatedGrid.getCell(row, col);

      // Clear value and make editable
      final updatedCell = cell.copyWith(
        clearValue: true,
        isFixed: false,
      );
      updatedGrid = updatedGrid.updateCell(updatedCell);
      removed++;
    }

    return updatedGrid;
  }

  /// Gets all 81 positions in grid
  List<List<int>> getAllPositions() {
    final positions = <List<int>>[];
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        positions.add([row, col]);
      }
    }
    return positions;
  }

  /// Shuffles positions list in place
  void shufflePositions(List<List<int>> positions) {
    positions.shuffle(_random);
  }

  /// Removes cells with pattern (symmetric removal)
  SudokuGridEntity removeCellsSymmetrically({
    required SudokuGridEntity grid,
    required int cellsToRemove,
  }) {
    var updatedGrid = grid;

    // Ensure even number for symmetry
    final pairsToRemove = cellsToRemove ~/ 2;

    // Get all positions
    final allPositions = getAllPositions();
    shufflePositions(allPositions);

    int removed = 0;
    for (final position in allPositions) {
      if (removed >= pairsToRemove) break;

      final row = position[0];
      final col = position[1];

      // Calculate symmetric position
      final symmetricRow = 8 - row;
      final symmetricCol = 8 - col;

      // Remove both cells
      final cell1 = updatedGrid.getCell(row, col);
      final cell2 = updatedGrid.getCell(symmetricRow, symmetricCol);

      final updatedCell1 = cell1.copyWith(clearValue: true, isFixed: false);
      final updatedCell2 = cell2.copyWith(clearValue: true, isFixed: false);

      updatedGrid = updatedGrid.updateCell(updatedCell1);
      updatedGrid = updatedGrid.updateCell(updatedCell2);

      removed++;
    }

    return updatedGrid;
  }

  // ============================================================================
  // Puzzle Validation
  // ============================================================================

  /// Checks if puzzle has unique solution (basic check)
  bool hasUniqueSolution(SudokuGridEntity puzzle) {
    int solutionCount = 0;
    _countSolutions(puzzle, (count) => solutionCount = count);
    return solutionCount == 1;
  }

  /// Counts number of solutions (stops at 2 for efficiency)
  void _countSolutions(SudokuGridEntity grid, Function(int) onCount) {
    int count = 0;

    void solve(SudokuGridEntity currentGrid) {
      if (count >= 2) return; // Stop if multiple solutions found

      // Find first empty cell
      bool foundEmpty = false;
      for (int row = 0; row < 9 && !foundEmpty; row++) {
        for (int col = 0; col < 9 && !foundEmpty; col++) {
          final cell = currentGrid.getCell(row, col);

          if (cell.isEmpty) {
            foundEmpty = true;

            // Try numbers 1-9
            for (int num = 1; num <= 9; num++) {
              if (currentGrid.isValidPlacement(row, col, num)) {
                final updatedCell = cell.copyWith(value: num);
                final newGrid = currentGrid.updateCell(updatedCell);
                solve(newGrid);
              }
            }
            return;
          }
        }
      }

      // All cells filled, found a solution
      if (!foundEmpty) {
        count++;
      }
    }

    solve(grid);
    onCount(count);
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets generation statistics
  GenerationStatistics getStatistics({
    required SudokuGridEntity solvedGrid,
    required SudokuGridEntity puzzle,
    required GameDifficulty difficulty,
  }) {
    final cluesCount = puzzle.cells.where((cell) => cell.isFixed).length;
    final emptyCells = puzzle.cells.where((cell) => cell.isEmpty).length;

    return GenerationStatistics(
      difficulty: difficulty,
      cluesProvided: cluesCount,
      emptyCells: emptyCells,
      expectedClues: difficulty.cluesCount,
      cellsRemoved: difficulty.cellsToRemove,
      difficultyMultiplier: difficulty.difficultyMultiplier,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Generation statistics
class GenerationStatistics {
  final GameDifficulty difficulty;
  final int cluesProvided;
  final int emptyCells;
  final int expectedClues;
  final int cellsRemoved;
  final double difficultyMultiplier;

  const GenerationStatistics({
    required this.difficulty,
    required this.cluesProvided,
    required this.emptyCells,
    required this.expectedClues,
    required this.cellsRemoved,
    required this.difficultyMultiplier,
  });

  /// Gets clue percentage
  double get cluePercentage => (cluesProvided / 81) * 100;

  /// Gets empty percentage
  double get emptyPercentage => (emptyCells / 81) * 100;

  /// Checks if generation matches expected values
  bool get isAccurate => cluesProvided == expectedClues;
}
