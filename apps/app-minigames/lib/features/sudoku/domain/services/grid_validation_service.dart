import '../entities/position_entity.dart';
import '../entities/sudoku_grid_entity.dart';

/// Service responsible for grid validation
///
/// Handles:
/// - Placement validation (row, column, block rules)
/// - Conflict detection
/// - Grid completeness checking
/// - Grid validity checking
class GridValidationService {
  GridValidationService();

  // ============================================================================
  // Placement Validation
  // ============================================================================

  /// Checks if a value can be placed at position without conflicts
  bool isValidPlacement({
    required SudokuGridEntity grid,
    required int row,
    required int col,
    required int value,
  }) {
    final position = PositionEntity(row: row, col: col);

    // Check all three constraints
    return !_hasRowConflict(grid, row, col, value) &&
        !_hasColumnConflict(grid, row, col, value) &&
        !_hasBlockConflict(grid, position, row, col, value);
  }

  /// Checks if value conflicts with row
  bool _hasRowConflict(
    SudokuGridEntity grid,
    int row,
    int col,
    int value,
  ) {
    final rowCells = grid.getRow(row);
    for (final cell in rowCells) {
      if (cell.col != col && cell.value == value) {
        return true;
      }
    }
    return false;
  }

  /// Checks if value conflicts with column
  bool _hasColumnConflict(
    SudokuGridEntity grid,
    int row,
    int col,
    int value,
  ) {
    final colCells = grid.getColumn(col);
    for (final cell in colCells) {
      if (cell.row != row && cell.value == value) {
        return true;
      }
    }
    return false;
  }

  /// Checks if value conflicts with 3x3 block
  bool _hasBlockConflict(
    SudokuGridEntity grid,
    PositionEntity position,
    int row,
    int col,
    int value,
  ) {
    final blockCells = grid.getBlock(position.blockIndex);
    for (final cell in blockCells) {
      if ((cell.row != row || cell.col != col) && cell.value == value) {
        return true;
      }
    }
    return false;
  }

  // ============================================================================
  // Conflict Detection
  // ============================================================================

  /// Checks if a cell has conflicts with other cells
  bool hasConflict({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    final cell = grid.getCell(row, col);
    if (cell.isEmpty) return false;

    final value = cell.value!;

    return _hasDuplicateInRow(grid, row, value) ||
        _hasDuplicateInColumn(grid, col, value) ||
        _hasDuplicateInBlock(grid, cell.blockIndex, value);
  }

  /// Checks if value appears more than once in row
  bool _hasDuplicateInRow(SudokuGridEntity grid, int row, int value) {
    final rowCells = grid.getRow(row);
    int count = 0;
    for (final cell in rowCells) {
      if (cell.value == value) count++;
    }
    return count > 1;
  }

  /// Checks if value appears more than once in column
  bool _hasDuplicateInColumn(SudokuGridEntity grid, int col, int value) {
    final colCells = grid.getColumn(col);
    int count = 0;
    for (final cell in colCells) {
      if (cell.value == value) count++;
    }
    return count > 1;
  }

  /// Checks if value appears more than once in block
  bool _hasDuplicateInBlock(SudokuGridEntity grid, int blockIndex, int value) {
    final blockCells = grid.getBlock(blockIndex);
    int count = 0;
    for (final cell in blockCells) {
      if (cell.value == value) count++;
    }
    return count > 1;
  }

  /// Gets all conflicts in grid
  ConflictAnalysis analyzeConflicts(SudokuGridEntity grid) {
    final conflictCells = <PositionEntity>[];
    final rowConflicts = <int, List<int>>{};
    final colConflicts = <int, List<int>>{};
    final blockConflicts = <int, List<int>>{};

    for (final cell in grid.cells) {
      if (cell.isEmpty) continue;

      final hasConflict = this.hasConflict(
        grid: grid,
        row: cell.row,
        col: cell.col,
      );

      if (hasConflict) {
        conflictCells.add(cell.position);

        // Track which rows have conflicts
        if (_hasDuplicateInRow(grid, cell.row, cell.value!)) {
          rowConflicts.putIfAbsent(cell.row, () => []).add(cell.value!);
        }

        // Track which columns have conflicts
        if (_hasDuplicateInColumn(grid, cell.col, cell.value!)) {
          colConflicts.putIfAbsent(cell.col, () => []).add(cell.value!);
        }

        // Track which blocks have conflicts
        if (_hasDuplicateInBlock(grid, cell.blockIndex, cell.value!)) {
          blockConflicts
              .putIfAbsent(cell.blockIndex, () => [])
              .add(cell.value!);
        }
      }
    }

    return ConflictAnalysis(
      hasConflicts: conflictCells.isNotEmpty,
      conflictCount: conflictCells.length,
      conflictPositions: conflictCells,
      rowConflicts: rowConflicts,
      columnConflicts: colConflicts,
      blockConflicts: blockConflicts,
    );
  }

  // ============================================================================
  // Grid State Validation
  // ============================================================================

  /// Checks if grid is completely filled
  bool isComplete(SudokuGridEntity grid) {
    return grid.cells.every((cell) => !cell.isEmpty);
  }

  /// Checks if grid is valid (no conflicts)
  bool isValid(SudokuGridEntity grid) {
    return grid.cells.every((cell) {
      if (cell.isEmpty) return true;
      return !hasConflict(grid: grid, row: cell.row, col: cell.col);
    });
  }

  /// Checks if grid is solved (complete and valid)
  bool isSolved(SudokuGridEntity grid) {
    return isComplete(grid) && isValid(grid);
  }

  /// Gets grid completion status
  GridCompletionStatus getCompletionStatus(SudokuGridEntity grid) {
    final emptyCount = grid.cells.where((cell) => cell.isEmpty).length;
    final filledCount = grid.cells.length - emptyCount;
    final progress = filledCount / grid.cells.length;

    final isComplete = this.isComplete(grid);
    final isValid = this.isValid(grid);
    final isSolved = isComplete && isValid;

    return GridCompletionStatus(
      filledCount: filledCount,
      emptyCount: emptyCount,
      totalCount: grid.cells.length,
      progress: progress,
      isComplete: isComplete,
      isValid: isValid,
      isSolved: isSolved,
    );
  }

  // ============================================================================
  // Cell Validation
  // ============================================================================

  /// Validates position bounds
  bool isValidPosition({required int row, required int col}) {
    return row >= 0 && row < 9 && col >= 0 && col < 9;
  }

  /// Validates value range
  bool isValidValue(int value) {
    return value >= 1 && value <= 9;
  }

  /// Validates note value range
  bool isValidNote(int note) {
    return note >= 1 && note <= 9;
  }

  /// Checks if cell is editable
  bool isCellEditable({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    if (!isValidPosition(row: row, col: col)) return false;

    final cell = grid.getCell(row, col);
    return cell.isEditable;
  }

  /// Gets cell editability status
  CellEditability getCellEditability({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    if (!isValidPosition(row: row, col: col)) {
      return const CellEditability(
        canEdit: false,
        reason: 'Position out of bounds',
      );
    }

    final cell = grid.getCell(row, col);

    if (cell.isFixed) {
      return const CellEditability(
        canEdit: false,
        reason: 'Cell is a fixed clue',
      );
    }

    return const CellEditability(
      canEdit: true,
      reason: null,
    );
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets grid statistics
  GridStatistics getStatistics(SudokuGridEntity grid) {
    final emptyCells = grid.cells.where((cell) => cell.isEmpty).toList();
    final filledCells = grid.cells.where((cell) => !cell.isEmpty).toList();
    final fixedCells = grid.cells.where((cell) => cell.isFixed).toList();
    final editableCells = filledCells.where((cell) => !cell.isFixed).toList();

    final cellsWithNotes = grid.cells.where((cell) => cell.hasNotes).toList();
    final totalNotes =
        cellsWithNotes.fold<int>(0, (sum, cell) => sum + cell.notes.length);

    final conflictAnalysis = analyzeConflicts(grid);
    final completionStatus = getCompletionStatus(grid);

    return GridStatistics(
      totalCells: grid.cells.length,
      emptyCells: emptyCells.length,
      filledCells: filledCells.length,
      fixedCells: fixedCells.length,
      editableCells: editableCells.length,
      cellsWithNotes: cellsWithNotes.length,
      totalNotes: totalNotes,
      averageNotesPerCell:
          cellsWithNotes.isEmpty ? 0.0 : totalNotes / cellsWithNotes.length,
      progress: completionStatus.progress,
      hasConflicts: conflictAnalysis.hasConflicts,
      conflictCount: conflictAnalysis.conflictCount,
      isComplete: completionStatus.isComplete,
      isValid: completionStatus.isValid,
      isSolved: completionStatus.isSolved,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Conflict analysis result
class ConflictAnalysis {
  final bool hasConflicts;
  final int conflictCount;
  final List<PositionEntity> conflictPositions;
  final Map<int, List<int>> rowConflicts; // row -> [values]
  final Map<int, List<int>> columnConflicts; // col -> [values]
  final Map<int, List<int>> blockConflicts; // block -> [values]

  const ConflictAnalysis({
    required this.hasConflicts,
    required this.conflictCount,
    required this.conflictPositions,
    required this.rowConflicts,
    required this.columnConflicts,
    required this.blockConflicts,
  });

  /// Gets total number of conflict areas
  int get totalConflictAreas =>
      rowConflicts.length + columnConflicts.length + blockConflicts.length;
}

/// Grid completion status
class GridCompletionStatus {
  final int filledCount;
  final int emptyCount;
  final int totalCount;
  final double progress; // 0.0 to 1.0
  final bool isComplete;
  final bool isValid;
  final bool isSolved;

  const GridCompletionStatus({
    required this.filledCount,
    required this.emptyCount,
    required this.totalCount,
    required this.progress,
    required this.isComplete,
    required this.isValid,
    required this.isSolved,
  });

  /// Gets progress as percentage
  double get progressPercentage => progress * 100;

  /// Gets remaining cells
  int get remainingCells => emptyCount;
}

/// Cell editability status
class CellEditability {
  final bool canEdit;
  final String? reason;

  const CellEditability({
    required this.canEdit,
    required this.reason,
  });
}

/// Grid statistics
class GridStatistics {
  final int totalCells;
  final int emptyCells;
  final int filledCells;
  final int fixedCells;
  final int editableCells;
  final int cellsWithNotes;
  final int totalNotes;
  final double averageNotesPerCell;
  final double progress;
  final bool hasConflicts;
  final int conflictCount;
  final bool isComplete;
  final bool isValid;
  final bool isSolved;

  const GridStatistics({
    required this.totalCells,
    required this.emptyCells,
    required this.filledCells,
    required this.fixedCells,
    required this.editableCells,
    required this.cellsWithNotes,
    required this.totalNotes,
    required this.averageNotesPerCell,
    required this.progress,
    required this.hasConflicts,
    required this.conflictCount,
    required this.isComplete,
    required this.isValid,
    required this.isSolved,
  });

  /// Gets progress as percentage
  double get progressPercentage => progress * 100;

  /// Gets fill rate
  double get fillRate => filledCells / totalCells;
}
