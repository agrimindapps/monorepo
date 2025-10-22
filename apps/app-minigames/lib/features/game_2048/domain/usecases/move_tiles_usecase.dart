import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../entities/enums.dart';
import '../entities/game_state_entity.dart';
import '../entities/grid_entity.dart';
import '../entities/position_entity.dart';
import '../entities/tile_entity.dart';

/// Handles tile movement and merging logic
class MoveTilesUseCase {
  /// Executes tile movement in specified direction
  /// Returns updated game state with new tile positions and score
  Future<Either<Failure, GameStateEntity>> call(
    GameStateEntity currentState,
    Direction direction,
  ) async {
    try {
      // Validation
      if (currentState.status != GameStatus.playing) {
        return Left(
          ValidationFailure('Cannot move tiles when game is not playing'),
        );
      }

      final grid = currentState.grid;
      final size = grid.size;
      final matrix = grid.toMatrix();

      // Track if any tile actually moved
      bool moved = false;
      int scoreGained = 0;
      final List<TileEntity> newTiles = [];
      final mergedTileIds = <String>{};

      // Process movement based on direction
      switch (direction) {
        case Direction.left:
          for (int row = 0; row < size; row++) {
            final result = _processLine(
              matrix[row],
              row,
              true,
              (col) => col,
            );
            newTiles.addAll(result.tiles);
            scoreGained += result.scoreGained;
            moved = moved || result.moved;
            mergedTileIds.addAll(result.mergedIds);
          }
          break;

        case Direction.right:
          for (int row = 0; row < size; row++) {
            final result = _processLine(
              matrix[row].reversed.toList(),
              row,
              true,
              (col) => size - 1 - col,
            );
            newTiles.addAll(result.tiles);
            scoreGained += result.scoreGained;
            moved = moved || result.moved;
            mergedTileIds.addAll(result.mergedIds);
          }
          break;

        case Direction.up:
          for (int col = 0; col < size; col++) {
            final column = List.generate(size, (row) => matrix[row][col]);
            final result = _processLine(
              column,
              col,
              false,
              (row) => row,
            );
            newTiles.addAll(result.tiles);
            scoreGained += result.scoreGained;
            moved = moved || result.moved;
            mergedTileIds.addAll(result.mergedIds);
          }
          break;

        case Direction.down:
          for (int col = 0; col < size; col++) {
            final column =
                List.generate(size, (row) => matrix[row][col]).reversed.toList();
            final result = _processLine(
              column,
              col,
              false,
              (row) => size - 1 - row,
            );
            newTiles.addAll(result.tiles);
            scoreGained += result.scoreGained;
            moved = moved || result.moved;
            mergedTileIds.addAll(result.mergedIds);
          }
          break;
      }

      // If no tiles moved, return current state unchanged
      if (!moved) {
        return Right(currentState);
      }

      // Update grid with new tiles
      final updatedGrid = grid.replaceTiles(newTiles);

      // Update game state
      final updatedState = currentState
          .copyWith(grid: updatedGrid)
          .addScore(scoreGained)
          .incrementMoves()
          .updateBestScore();

      return Right(updatedState);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Processes a single line (row or column) of tiles
  _LineProcessResult _processLine(
    List<TileEntity?> line,
    int fixedCoordinate,
    bool isRow,
    int Function(int) calculateVaryingCoordinate,
  ) {
    final List<TileEntity> processedTiles = [];
    final mergedIds = <String>{};
    int scoreGained = 0;
    bool moved = false;

    // Extract non-null tiles
    final nonEmptyTiles = line.whereType<TileEntity>().toList();

    // Original positions for movement detection
    final originalPositions = <String, PositionEntity>{};
    for (final tile in nonEmptyTiles) {
      originalPositions[tile.id] = tile.position;
    }

    // Process merges and movement
    int targetIndex = 0;
    int i = 0;

    while (i < nonEmptyTiles.length) {
      final currentTile = nonEmptyTiles[i];

      // Check if we can merge with next tile
      if (i + 1 < nonEmptyTiles.length &&
          currentTile.value == nonEmptyTiles[i + 1].value) {
        // Merge tiles
        final mergedValue = currentTile.value * 2;
        scoreGained += mergedValue;

        final newPosition = isRow
            ? PositionEntity(
                row: fixedCoordinate,
                col: calculateVaryingCoordinate(targetIndex),
              )
            : PositionEntity(
                row: calculateVaryingCoordinate(targetIndex),
                col: fixedCoordinate,
              );

        final mergedTile = TileEntity(
          id: currentTile.id, // Keep first tile's ID
          value: mergedValue,
          position: newPosition,
          animationType: AnimationType.merge,
        );

        processedTiles.add(mergedTile);
        mergedIds.add(currentTile.id);
        mergedIds.add(nonEmptyTiles[i + 1].id);

        moved = true;
        i += 2; // Skip both merged tiles
        targetIndex++;
      } else {
        // Just move tile
        final newPosition = isRow
            ? PositionEntity(
                row: fixedCoordinate,
                col: calculateVaryingCoordinate(targetIndex),
              )
            : PositionEntity(
                row: calculateVaryingCoordinate(targetIndex),
                col: fixedCoordinate,
              );

        final movedTile = currentTile.copyWith(
          position: newPosition,
          animationType: originalPositions[currentTile.id]!.isSameAs(newPosition)
              ? AnimationType.none
              : AnimationType.move,
        );

        processedTiles.add(movedTile);

        if (!originalPositions[currentTile.id]!.isSameAs(newPosition)) {
          moved = true;
        }

        i++;
        targetIndex++;
      }
    }

    return _LineProcessResult(
      tiles: processedTiles,
      scoreGained: scoreGained,
      moved: moved,
      mergedIds: mergedIds,
    );
  }
}

/// Result of processing a single line
class _LineProcessResult {
  final List<TileEntity> tiles;
  final int scoreGained;
  final bool moved;
  final Set<String> mergedIds;

  _LineProcessResult({
    required this.tiles,
    required this.scoreGained,
    required this.moved,
    required this.mergedIds,
  });
}
