import '../entities/sudoku_grid_entity.dart';
import 'grid_validation_service.dart';

/// Service responsible for conflict management
///
/// Handles:
/// - Conflict detection across grid
/// - Conflict marking and clearing
/// - Conflict updates after moves
class ConflictManagerService {
  final GridValidationService _gridValidation;

  ConflictManagerService(this._gridValidation);

  // ============================================================================
  // Conflict Update
  // ============================================================================

  /// Updates all conflicts in the grid
  SudokuGridEntity updateAllConflicts(SudokuGridEntity grid) {
    // First pass: clear all conflicts
    var updatedGrid = _clearAllConflicts(grid);

    // Second pass: detect and mark conflicts
    updatedGrid = _markAllConflicts(updatedGrid);

    return updatedGrid;
  }

  /// Clears all conflict markers from grid
  SudokuGridEntity _clearAllConflicts(SudokuGridEntity grid) {
    var updatedGrid = grid;

    for (final cell in grid.cells) {
      if (cell.hasConflict) {
        final clearedCell = cell.copyWith(hasConflict: false);
        updatedGrid = updatedGrid.updateCell(clearedCell);
      }
    }

    return updatedGrid;
  }

  /// Marks all cells with conflicts
  SudokuGridEntity _markAllConflicts(SudokuGridEntity grid) {
    var updatedGrid = grid;

    for (final cell in grid.cells) {
      if (cell.isEmpty) continue;

      final hasConflict = _gridValidation.hasConflict(
        grid: updatedGrid,
        row: cell.row,
        col: cell.col,
      );

      if (hasConflict) {
        final conflictCell = cell.copyWith(hasConflict: true);
        updatedGrid = updatedGrid.updateCell(conflictCell);
      }
    }

    return updatedGrid;
  }

  // ============================================================================
  // Selective Conflict Update
  // ============================================================================

  /// Updates conflicts only for cells related to a specific position
  SudokuGridEntity updateRelatedConflicts({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    var updatedGrid = grid;

    // Get cell at position
    final targetCell = grid.getCell(row, col);

    // Get all related cells (same row, column, or block)
    final relatedCells = grid.getRelatedCells(targetCell.position);

    // Update target cell conflict status
    final targetHasConflict = _gridValidation.hasConflict(
      grid: updatedGrid,
      row: row,
      col: col,
    );
    final updatedTargetCell =
        targetCell.copyWith(hasConflict: targetHasConflict);
    updatedGrid = updatedGrid.updateCell(updatedTargetCell);

    // Update related cells conflict status
    for (final relatedCell in relatedCells) {
      if (relatedCell.isEmpty) continue;

      final hasConflict = _gridValidation.hasConflict(
        grid: updatedGrid,
        row: relatedCell.row,
        col: relatedCell.col,
      );

      final currentCell = updatedGrid.getCell(relatedCell.row, relatedCell.col);
      if (currentCell.hasConflict != hasConflict) {
        final updatedCell = currentCell.copyWith(hasConflict: hasConflict);
        updatedGrid = updatedGrid.updateCell(updatedCell);
      }
    }

    return updatedGrid;
  }

  // ============================================================================
  // Conflict Clearing
  // ============================================================================

  /// Clears conflict from specific cell
  SudokuGridEntity clearCellConflict({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    final cell = grid.getCell(row, col);

    if (!cell.hasConflict) {
      return grid;
    }

    final clearedCell = cell.copyWith(hasConflict: false);
    return grid.updateCell(clearedCell);
  }

  /// Clears conflicts from multiple cells
  SudokuGridEntity clearCellsConflicts({
    required SudokuGridEntity grid,
    required List<(int, int)> positions,
  }) {
    var updatedGrid = grid;

    for (final (row, col) in positions) {
      updatedGrid = clearCellConflict(
        grid: updatedGrid,
        row: row,
        col: col,
      );
    }

    return updatedGrid;
  }

  // ============================================================================
  // Conflict Marking
  // ============================================================================

  /// Marks cell with conflict
  SudokuGridEntity markCellConflict({
    required SudokuGridEntity grid,
    required int row,
    required int col,
  }) {
    final cell = grid.getCell(row, col);

    if (cell.hasConflict) {
      return grid;
    }

    final conflictCell = cell.copyWith(hasConflict: true);
    return grid.updateCell(conflictCell);
  }

  /// Marks multiple cells with conflicts
  SudokuGridEntity markCellsConflicts({
    required SudokuGridEntity grid,
    required List<(int, int)> positions,
  }) {
    var updatedGrid = grid;

    for (final (row, col) in positions) {
      updatedGrid = markCellConflict(
        grid: updatedGrid,
        row: row,
        col: col,
      );
    }

    return updatedGrid;
  }

  // ============================================================================
  // Conflict Analysis
  // ============================================================================

  /// Gets detailed conflict analysis
  ConflictReport getConflictReport(SudokuGridEntity grid) {
    final analysis = _gridValidation.analyzeConflicts(grid);

    // Group conflicts by type
    final rowConflictCells = <int, List<(int, int)>>{};
    final colConflictCells = <int, List<(int, int)>>{};
    final blockConflictCells = <int, List<(int, int)>>{};

    for (final position in analysis.conflictPositions) {
      final cell = grid.getCellAt(position);

      // Check which type of conflict
      if (_gridValidation.hasConflict(
        grid: grid,
        row: position.row,
        col: position.col,
      )) {
        // Add to row conflicts
        if (analysis.rowConflicts.containsKey(position.row)) {
          rowConflictCells
              .putIfAbsent(position.row, () => [])
              .add((position.row, position.col));
        }

        // Add to column conflicts
        if (analysis.columnConflicts.containsKey(position.col)) {
          colConflictCells
              .putIfAbsent(position.col, () => [])
              .add((position.row, position.col));
        }

        // Add to block conflicts
        if (analysis.blockConflicts.containsKey(cell.blockIndex)) {
          blockConflictCells
              .putIfAbsent(cell.blockIndex, () => [])
              .add((position.row, position.col));
        }
      }
    }

    return ConflictReport(
      totalConflicts: analysis.conflictCount,
      hasConflicts: analysis.hasConflicts,
      rowConflicts: analysis.rowConflicts.length,
      columnConflicts: analysis.columnConflicts.length,
      blockConflicts: analysis.blockConflicts.length,
      rowConflictCells: rowConflictCells,
      columnConflictCells: colConflictCells,
      blockConflictCells: blockConflictCells,
    );
  }

  /// Checks if grid has any conflicts
  bool hasAnyConflicts(SudokuGridEntity grid) {
    return grid.cells.any((cell) => cell.hasConflict);
  }

  /// Gets count of cells with conflicts
  int getConflictCount(SudokuGridEntity grid) {
    return grid.cells.where((cell) => cell.hasConflict).length;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets conflict statistics
  ConflictStatistics getStatistics(SudokuGridEntity grid) {
    final report = getConflictReport(grid);
    final conflictCells = grid.cells.where((cell) => cell.hasConflict).toList();
    final filledCells = grid.cells.where((cell) => !cell.isEmpty).length;

    final conflictRate =
        filledCells > 0 ? conflictCells.length / filledCells : 0.0;

    return ConflictStatistics(
      totalConflicts: report.totalConflicts,
      rowConflicts: report.rowConflicts,
      columnConflicts: report.columnConflicts,
      blockConflicts: report.blockConflicts,
      conflictRate: conflictRate,
      hasConflicts: report.hasConflicts,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Conflict report with detailed information
class ConflictReport {
  final int totalConflicts;
  final bool hasConflicts;
  final int rowConflicts;
  final int columnConflicts;
  final int blockConflicts;
  final Map<int, List<(int, int)>> rowConflictCells;
  final Map<int, List<(int, int)>> columnConflictCells;
  final Map<int, List<(int, int)>> blockConflictCells;

  const ConflictReport({
    required this.totalConflicts,
    required this.hasConflicts,
    required this.rowConflicts,
    required this.columnConflicts,
    required this.blockConflicts,
    required this.rowConflictCells,
    required this.columnConflictCells,
    required this.blockConflictCells,
  });

  /// Gets total conflict areas
  int get totalConflictAreas => rowConflicts + columnConflicts + blockConflicts;

  /// Gets severity level
  ConflictSeverity get severity {
    if (totalConflicts == 0) {
      return ConflictSeverity.none;
    } else if (totalConflicts <= 2) {
      return ConflictSeverity.low;
    } else if (totalConflicts <= 5) {
      return ConflictSeverity.medium;
    } else if (totalConflicts <= 10) {
      return ConflictSeverity.high;
    } else {
      return ConflictSeverity.critical;
    }
  }
}

/// Conflict severity level
enum ConflictSeverity {
  none,
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case ConflictSeverity.none:
        return 'Sem Conflitos';
      case ConflictSeverity.low:
        return 'Conflitos Baixos';
      case ConflictSeverity.medium:
        return 'Conflitos Médios';
      case ConflictSeverity.high:
        return 'Conflitos Altos';
      case ConflictSeverity.critical:
        return 'Conflitos Críticos';
    }
  }

  String get emoji {
    switch (this) {
      case ConflictSeverity.none:
        return '✅';
      case ConflictSeverity.low:
        return '⚠️';
      case ConflictSeverity.medium:
        return '⚠️';
      case ConflictSeverity.high:
        return '❌';
      case ConflictSeverity.critical:
        return '🔴';
    }
  }
}

/// Conflict statistics
class ConflictStatistics {
  final int totalConflicts;
  final int rowConflicts;
  final int columnConflicts;
  final int blockConflicts;
  final double conflictRate;
  final bool hasConflicts;

  const ConflictStatistics({
    required this.totalConflicts,
    required this.rowConflicts,
    required this.columnConflicts,
    required this.blockConflicts,
    required this.conflictRate,
    required this.hasConflicts,
  });

  /// Gets conflict rate as percentage
  double get conflictRatePercentage => conflictRate * 100;

  /// Gets total conflict types
  int get conflictTypes {
    int types = 0;
    if (rowConflicts > 0) types++;
    if (columnConflicts > 0) types++;
    if (blockConflicts > 0) types++;
    return types;
  }
}
