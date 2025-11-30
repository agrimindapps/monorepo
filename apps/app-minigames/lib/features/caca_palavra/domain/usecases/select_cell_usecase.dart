import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/position.dart';

/// Handles cell selection logic with adjacency and alignment validation
class SelectCellUseCase {
  Either<Failure, GameState> call({
    required GameState currentState,
    required int row,
    required int col,
  }) {
    try {
      // Validate if game is still playing
      if (!currentState.isPlaying) {
        return const Left(ValidationFailure('Game is not in playing state'));
      }

      // Validate position bounds
      if (row < 0 || row >= currentState.gridSize ||
          col < 0 || col >= currentState.gridSize) {
        return const Left(ValidationFailure('Invalid grid position'));
      }

      final position = Position(row, col);
      final selectedPositions = List<Position>.from(currentState.selectedPositions);

      // Logic for selection
      if (selectedPositions.isEmpty) {
        // First selection - always allowed
        selectedPositions.add(position);
      } else if (_isAdjacentAndAligned(position, selectedPositions)) {
        // Adjacent and aligned - add to selection
        selectedPositions.add(position);
      } else if (selectedPositions.contains(position)) {
        // Already selected
        if (position == selectedPositions.last) {
          // Last position - remove it (undo)
          selectedPositions.removeLast();
        } else {
          // Not last - clear all selection
          selectedPositions.clear();
        }
      } else {
        // Not adjacent or aligned - clear and start new selection
        selectedPositions.clear();
        selectedPositions.add(position);
      }

      return Right(currentState.copyWith(selectedPositions: selectedPositions));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to select cell: ${e.toString()}'));
    }
  }

  /// Checks if position is adjacent to last selected and maintains alignment
  bool _isAdjacentAndAligned(Position position, List<Position> selected) {
    if (selected.isEmpty) return true;

    final lastPos = selected.last;
    final rowDiff = position.row - lastPos.row;
    final colDiff = position.col - lastPos.col;

    // Check adjacency (max 1 step in any direction)
    final isAdjacent = rowDiff.abs() <= 1 && colDiff.abs() <= 1;
    if (!isAdjacent) return false;

    // First selection after initial - any adjacent is valid
    if (selected.length <= 1) return true;

    // Check alignment with previous direction
    final prevPos = selected[selected.length - 2];
    final prevRowDiff = lastPos.row - prevPos.row;
    final prevColDiff = lastPos.col - prevPos.col;

    // Must maintain same direction
    return rowDiff == prevRowDiff && colDiff == prevColDiff;
  }
}
