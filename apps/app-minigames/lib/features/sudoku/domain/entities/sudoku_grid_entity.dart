import 'package:equatable/equatable.dart';
import 'position_entity.dart';
import 'sudoku_cell_entity.dart';

class SudokuGridEntity extends Equatable {
  static const int gridSize = 9;

  final List<SudokuCellEntity> cells;

  const SudokuGridEntity({required this.cells});

  /// Factory for empty grid
  factory SudokuGridEntity.empty() {
    final cells = <SudokuCellEntity>[];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        cells.add(SudokuCellEntity.empty(row, col));
      }
    }
    return SudokuGridEntity(cells: cells);
  }

  /// Factory from 2D array
  factory SudokuGridEntity.fromArray(List<List<int>> array) {
    final cells = <SudokuCellEntity>[];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final value = array[row][col];
        if (value == 0) {
          cells.add(SudokuCellEntity.empty(row, col));
        } else {
          cells.add(SudokuCellEntity.fixed(row, col, value));
        }
      }
    }
    return SudokuGridEntity(cells: cells);
  }

  /// Get cell at position
  SudokuCellEntity getCell(int row, int col) {
    final index = row * gridSize + col;
    return cells[index];
  }

  /// Get cell by position entity
  SudokuCellEntity getCellAt(PositionEntity position) {
    return getCell(position.row, position.col);
  }

  /// Update cell
  SudokuGridEntity updateCell(SudokuCellEntity updatedCell) {
    final index = updatedCell.row * gridSize + updatedCell.col;
    final newCells = List<SudokuCellEntity>.from(cells);
    newCells[index] = updatedCell;
    return SudokuGridEntity(cells: newCells);
  }

  /// Get all cells in a row
  List<SudokuCellEntity> getRow(int row) {
    return cells.where((cell) => cell.row == row).toList();
  }

  /// Get all cells in a column
  List<SudokuCellEntity> getColumn(int col) {
    return cells.where((cell) => cell.col == col).toList();
  }

  /// Get all cells in a 3x3 block
  List<SudokuCellEntity> getBlock(int blockIndex) {
    return cells.where((cell) => cell.blockIndex == blockIndex).toList();
  }

  /// Get all cells related to a position (same row, col, or block)
  List<SudokuCellEntity> getRelatedCells(PositionEntity position) {
    return cells.where((cell) {
      if (cell.position == position) return false; // Exclude self
      return cell.position.isRelated(position);
    }).toList();
  }

  /// Get all empty cells
  List<SudokuCellEntity> getEmptyCells() {
    return cells.where((cell) => cell.isEmpty).toList();
  }

  /// Get all fixed cells
  List<SudokuCellEntity> getFixedCells() {
    return cells.where((cell) => cell.isFixed).toList();
  }

  /// Get all cells with conflicts
  List<SudokuCellEntity> getConflictCells() {
    return cells.where((cell) => cell.hasConflict).toList();
  }

  /// Check if a value can be placed at position (no conflicts)
  bool isValidPlacement(int row, int col, int value) {
    final position = PositionEntity(row: row, col: col);

    // Check row for duplicates
    final rowCells = getRow(row);
    for (final cell in rowCells) {
      if (cell.col != col && cell.value == value) {
        return false;
      }
    }

    // Check column for duplicates
    final colCells = getColumn(col);
    for (final cell in colCells) {
      if (cell.row != row && cell.value == value) {
        return false;
      }
    }

    // Check 3x3 block for duplicates
    final blockCells = getBlock(position.blockIndex);
    for (final cell in blockCells) {
      if ((cell.row != row || cell.col != col) && cell.value == value) {
        return false;
      }
    }

    return true;
  }

  /// Check if grid is completely filled
  bool get isComplete {
    return cells.every((cell) => !cell.isEmpty);
  }

  /// Check if grid is valid (no conflicts)
  bool get isValid {
    return cells.every((cell) => !cell.hasConflict);
  }

  /// Check if grid is solved (complete and valid)
  bool get isSolved {
    return isComplete && isValid;
  }

  /// Count empty cells
  int get emptyCount {
    return cells.where((cell) => cell.isEmpty).length;
  }

  /// Count filled cells
  int get filledCount {
    return cells.where((cell) => !cell.isEmpty).length;
  }

  /// Convert to 2D array (for serialization or algorithms)
  List<List<int>> toArray() {
    final array = List.generate(gridSize, (_) => List<int>.filled(gridSize, 0));
    for (final cell in cells) {
      array[cell.row][cell.col] = cell.value ?? 0;
    }
    return array;
  }

  SudokuGridEntity copyWith({List<SudokuCellEntity>? cells}) {
    return SudokuGridEntity(cells: cells ?? this.cells);
  }

  @override
  List<Object?> get props => [cells];

  @override
  String toString() =>
      'Grid(filled: $filledCount/81, empty: $emptyCount, complete: $isComplete, valid: $isValid)';
}
