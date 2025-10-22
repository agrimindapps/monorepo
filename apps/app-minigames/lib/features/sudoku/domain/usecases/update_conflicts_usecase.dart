import '../entities/sudoku_grid_entity.dart';

/// Use case for updating conflict status across the grid
///
/// Scans all cells and marks conflicts where:
/// - Same number appears in same row
/// - Same number appears in same column
/// - Same number appears in same 3x3 block
class UpdateConflictsUseCase {
  /// Update all conflicts in grid
  SudokuGridEntity call(SudokuGridEntity grid) {
    var updatedGrid = grid;

    // First pass: clear all conflicts
    for (final cell in grid.cells) {
      if (cell.hasConflict) {
        final clearedCell = cell.copyWith(hasConflict: false);
        updatedGrid = updatedGrid.updateCell(clearedCell);
      }
    }

    // Second pass: detect and mark conflicts
    for (final cell in updatedGrid.cells) {
      if (cell.isEmpty) continue;

      final hasConflict = _checkConflict(updatedGrid, cell.row, cell.col);
      if (hasConflict) {
        final conflictCell = cell.copyWith(hasConflict: true);
        updatedGrid = updatedGrid.updateCell(conflictCell);
      }
    }

    return updatedGrid;
  }

  /// Check if a cell has conflicts
  bool _checkConflict(SudokuGridEntity grid, int row, int col) {
    final cell = grid.getCell(row, col);
    if (cell.isEmpty) return false;

    final value = cell.value!;

    // Check row for duplicates
    final rowCells = grid.getRow(row);
    int rowCount = 0;
    for (final c in rowCells) {
      if (c.value == value) rowCount++;
    }
    if (rowCount > 1) return true;

    // Check column for duplicates
    final colCells = grid.getColumn(col);
    int colCount = 0;
    for (final c in colCells) {
      if (c.value == value) colCount++;
    }
    if (colCount > 1) return true;

    // Check 3x3 block for duplicates
    final blockCells = grid.getBlock(cell.blockIndex);
    int blockCount = 0;
    for (final c in blockCells) {
      if (c.value == value) blockCount++;
    }
    if (blockCount > 1) return true;

    return false;
  }
}
