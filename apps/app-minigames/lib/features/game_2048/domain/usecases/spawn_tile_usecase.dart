import 'dart:math';

import 'package:core/core.dart';

import '../entities/grid_entity.dart';
import '../entities/tile_entity.dart';

/// Spawns a new tile (2 or 4) in a random empty position
class SpawnTileUseCase {
  final Random _random = Random();

  /// Spawns a new tile in the grid
  /// Returns updated grid with new tile
  Future<Either<Failure, GridEntity>> call(GridEntity grid) async {
    try {
      // Get empty positions
      final emptyPositions = grid.getEmptyPositions();

      // Validation: grid must have empty space
      if (emptyPositions.isEmpty) {
        return const Left(ValidationFailure('No empty positions to spawn tile'));
      }

      // Select random position
      final randomPosition =
          emptyPositions[_random.nextInt(emptyPositions.length)];

      // Determine tile value: 90% chance of 2, 10% chance of 4
      final value = _random.nextInt(10) < 9 ? 2 : 4;

      // Create new tile with spawn animation
      final newTile = TileEntity.spawn(value: value, position: randomPosition);

      // Add tile to grid
      final updatedGrid = grid.addTile(newTile);

      return Right(updatedGrid);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Spawns multiple tiles (used for game initialization)
  Future<Either<Failure, GridEntity>> spawnMultiple(
    GridEntity grid,
    int count,
  ) async {
    try {
      if (count < 1) {
        return const Left(ValidationFailure('Count must be at least 1'));
      }

      GridEntity currentGrid = grid;

      for (int i = 0; i < count; i++) {
        final result = await call(currentGrid);

        // If any spawn fails, return the failure
        if (result.isLeft()) {
          return result;
        }

        currentGrid = result.getOrElse(() => currentGrid);
      }

      return Right(currentGrid);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
