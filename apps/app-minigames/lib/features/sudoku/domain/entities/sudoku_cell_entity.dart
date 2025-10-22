import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'position_entity.dart';

class SudokuCellEntity extends Equatable {
  final PositionEntity position;
  final int? value; // 1-9 or null if empty
  final bool isFixed; // Given clue (non-editable)
  final Set<int> notes; // Pencil marks (1-9)
  final CellState state; // normal, selected, error, highlighted, sameNumber
  final bool hasConflict; // True if violates sudoku rules

  const SudokuCellEntity({
    required this.position,
    this.value,
    this.isFixed = false,
    this.notes = const {},
    this.state = CellState.normal,
    this.hasConflict = false,
  });

  /// Factory for empty cell
  factory SudokuCellEntity.empty(int row, int col) {
    return SudokuCellEntity(
      position: PositionEntity(row: row, col: col),
      value: null,
      isFixed: false,
      notes: const {},
      state: CellState.normal,
      hasConflict: false,
    );
  }

  /// Factory for fixed cell (given clue)
  factory SudokuCellEntity.fixed(int row, int col, int value) {
    return SudokuCellEntity(
      position: PositionEntity(row: row, col: col),
      value: value,
      isFixed: true,
      notes: const {},
      state: CellState.normal,
      hasConflict: false,
    );
  }

  /// Convenience getters
  int get row => position.row;
  int get col => position.col;
  int get blockIndex => position.blockIndex;

  bool get isEmpty => value == null;
  bool get isEditable => !isFixed;
  bool get hasNotes => notes.isNotEmpty;
  bool get isValid => !hasConflict;

  /// Check if cell can accept input
  bool get canEdit => isEditable && !hasConflict;

  /// Add note (only if cell is empty and editable)
  SudokuCellEntity addNote(int note) {
    if (!isEmpty || !isEditable || note < 1 || note > 9) {
      return this;
    }
    return copyWith(notes: {...notes, note});
  }

  /// Remove note
  SudokuCellEntity removeNote(int note) {
    if (!notes.contains(note)) return this;
    final updatedNotes = Set<int>.from(notes)..remove(note);
    return copyWith(notes: updatedNotes);
  }

  /// Toggle note (add if absent, remove if present)
  SudokuCellEntity toggleNote(int note) {
    if (notes.contains(note)) {
      return removeNote(note);
    } else {
      return addNote(note);
    }
  }

  /// Clear all notes
  SudokuCellEntity clearNotes() {
    return copyWith(notes: const {});
  }

  /// Place value (clears notes)
  SudokuCellEntity placeValue(int? newValue) {
    if (!isEditable) return this;
    return copyWith(
      value: newValue,
      notes: const {}, // Clear notes when placing value
      hasConflict: false, // Will be recalculated
    );
  }

  SudokuCellEntity copyWith({
    PositionEntity? position,
    int? value,
    bool clearValue = false,
    bool? isFixed,
    Set<int>? notes,
    CellState? state,
    bool? hasConflict,
  }) {
    return SudokuCellEntity(
      position: position ?? this.position,
      value: clearValue ? null : (value ?? this.value),
      isFixed: isFixed ?? this.isFixed,
      notes: notes ?? this.notes,
      state: state ?? this.state,
      hasConflict: hasConflict ?? this.hasConflict,
    );
  }

  @override
  List<Object?> get props => [
        position,
        value,
        isFixed,
        notes,
        state,
        hasConflict,
      ];

  @override
  String toString() =>
      'Cell(${position.row},${position.col}): ${value ?? "empty"}, fixed: $isFixed, notes: $notes';
}
