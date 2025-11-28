import 'package:equatable/equatable.dart';
import 'position_entity.dart';

/// Type of move in Sudoku
enum MoveType {
  placeNumber('Colocou número'),
  clearCell('Limpou célula'),
  addNote('Adicionou nota'),
  removeNote('Removeu nota'),
  toggleNote('Alternou nota'),
  hint('Usou dica');

  final String label;
  const MoveType(this.label);
}

/// Represents a single move in Sudoku
class SudokuMove extends Equatable {
  final PositionEntity position;
  final int? previousValue;
  final int? newValue;
  final Set<int> previousNotes;
  final Set<int> newNotes;
  final DateTime timestamp;
  final MoveType type;

  const SudokuMove({
    required this.position,
    required this.previousValue,
    required this.newValue,
    required this.previousNotes,
    required this.newNotes,
    required this.timestamp,
    required this.type,
  });

  /// Factory for placing a number
  factory SudokuMove.placeNumber({
    required PositionEntity position,
    required int? previousValue,
    required int newValue,
    required Set<int> previousNotes,
  }) {
    return SudokuMove(
      position: position,
      previousValue: previousValue,
      newValue: newValue,
      previousNotes: previousNotes,
      newNotes: const {},
      timestamp: DateTime.now(),
      type: MoveType.placeNumber,
    );
  }

  /// Factory for clearing a cell
  factory SudokuMove.clearCell({
    required PositionEntity position,
    required int previousValue,
    required Set<int> previousNotes,
  }) {
    return SudokuMove(
      position: position,
      previousValue: previousValue,
      newValue: null,
      previousNotes: previousNotes,
      newNotes: const {},
      timestamp: DateTime.now(),
      type: MoveType.clearCell,
    );
  }

  /// Factory for toggling a note
  factory SudokuMove.toggleNote({
    required PositionEntity position,
    required int note,
    required Set<int> previousNotes,
    required Set<int> newNotes,
  }) {
    final wasAdded = newNotes.contains(note) && !previousNotes.contains(note);
    return SudokuMove(
      position: position,
      previousValue: null,
      newValue: note,
      previousNotes: previousNotes,
      newNotes: newNotes,
      timestamp: DateTime.now(),
      type: wasAdded ? MoveType.addNote : MoveType.removeNote,
    );
  }

  /// Factory for a hint move
  factory SudokuMove.hint({
    required PositionEntity position,
    required int? previousValue,
    required int hintValue,
    required Set<int> previousNotes,
  }) {
    return SudokuMove(
      position: position,
      previousValue: previousValue,
      newValue: hintValue,
      previousNotes: previousNotes,
      newNotes: const {},
      timestamp: DateTime.now(),
      type: MoveType.hint,
    );
  }

  /// Check if this move changed the cell value
  bool get changedValue => previousValue != newValue;

  /// Check if this move changed notes
  bool get changedNotes => previousNotes != newNotes;

  @override
  List<Object?> get props => [
        position,
        previousValue,
        newValue,
        previousNotes,
        newNotes,
        timestamp,
        type,
      ];

  @override
  String toString() =>
      'Move($type at ${position.row},${position.col}: $previousValue -> $newValue)';
}

/// Move history with undo/redo support
class MoveHistory extends Equatable {
  /// All moves in history
  final List<SudokuMove> moves;

  /// Current position in history (-1 = no moves, 0+ = current position)
  final int currentIndex;

  /// Maximum history size (to prevent memory issues)
  static const int maxHistorySize = 1000;

  const MoveHistory({
    this.moves = const [],
    this.currentIndex = -1,
  });

  /// Create empty history
  factory MoveHistory.empty() => const MoveHistory();

  /// Whether undo is available
  bool get canUndo => currentIndex >= 0;

  /// Whether redo is available
  bool get canRedo => currentIndex < moves.length - 1;

  /// Number of undoable moves
  int get undoCount => currentIndex + 1;

  /// Number of redoable moves
  int get redoCount => moves.length - 1 - currentIndex;

  /// Total moves made
  int get totalMoves => moves.length;

  /// Get the current move (or null if none)
  SudokuMove? get currentMove =>
      canUndo ? moves[currentIndex] : null;

  /// Get the next move for redo (or null if none)
  SudokuMove? get nextMove =>
      canRedo ? moves[currentIndex + 1] : null;

  /// Get last N moves (for display)
  List<SudokuMove> getLastMoves(int count) {
    if (moves.isEmpty) return [];
    final start = (currentIndex - count + 1).clamp(0, currentIndex + 1);
    final end = currentIndex + 1;
    return moves.sublist(start, end);
  }

  /// Add a new move to history
  /// If we're not at the end of history, truncate forward history
  MoveHistory addMove(SudokuMove move) {
    // Truncate any forward history
    final newMoves = currentIndex < 0
        ? <SudokuMove>[]
        : moves.sublist(0, currentIndex + 1);

    // Add the new move
    newMoves.add(move);

    // Limit history size
    if (newMoves.length > maxHistorySize) {
      newMoves.removeAt(0);
    }

    return MoveHistory(
      moves: newMoves,
      currentIndex: newMoves.length - 1,
    );
  }

  /// Undo the current move
  /// Returns (newHistory, moveToUndo) or (this, null) if can't undo
  (MoveHistory, SudokuMove?) undo() {
    if (!canUndo) return (this, null);

    final moveToUndo = moves[currentIndex];
    return (
      MoveHistory(
        moves: moves,
        currentIndex: currentIndex - 1,
      ),
      moveToUndo,
    );
  }

  /// Redo the next move
  /// Returns (newHistory, moveToRedo) or (this, null) if can't redo
  (MoveHistory, SudokuMove?) redo() {
    if (!canRedo) return (this, null);

    final moveToRedo = moves[currentIndex + 1];
    return (
      MoveHistory(
        moves: moves,
        currentIndex: currentIndex + 1,
      ),
      moveToRedo,
    );
  }

  /// Clear all history
  MoveHistory clear() => MoveHistory.empty();

  /// Copy with new values
  MoveHistory copyWith({
    List<SudokuMove>? moves,
    int? currentIndex,
  }) {
    return MoveHistory(
      moves: moves ?? this.moves,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [moves, currentIndex];

  @override
  String toString() =>
      'MoveHistory(moves: ${moves.length}, index: $currentIndex, canUndo: $canUndo, canRedo: $canRedo)';
}
