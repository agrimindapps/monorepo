import 'package:core/core.dart';

import '../entities/grid_entity.dart';
import '../entities/position_entity.dart';

/// Checks if the game is over (no valid moves available)
class CheckGameOverUseCase {
  /// Checks if any moves are possible
  /// Returns true if game is over, false if moves are available
  Future<Either<Failure, bool>> call(GridEntity grid) async {
    try {
      final size = grid.size;

      // If there are empty positions, game is not over
      if (grid.getEmptyPositions().isNotEmpty) {
        return const Right(false);
      }

      // Grid is full, check for possible merges
      // Check horizontal merges
      for (int row = 0; row < size; row++) {
        for (int col = 0; col < size - 1; col++) {
          final current = grid.getTileAt(PositionEntity(row: row, col: col));
          final next = grid.getTileAt(PositionEntity(row: row, col: col + 1));

          if (current != null && next != null && current.value == next.value) {
            return const Right(false); // Merge possible
          }
        }
      }

      // Check vertical merges
      for (int col = 0; col < size; col++) {
        for (int row = 0; row < size - 1; row++) {
          final current = grid.getTileAt(PositionEntity(row: row, col: col));
          final next = grid.getTileAt(PositionEntity(row: row + 1, col: col));

          if (current != null && next != null && current.value == next.value) {
            return const Right(false); // Merge possible
          }
        }
      }

      // No moves available - game over
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
