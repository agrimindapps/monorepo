import 'package:core/core.dart';

import '../entities/enums.dart';
import '../entities/game_state_entity.dart';
import '../entities/grid_entity.dart';
import 'spawn_tile_usecase.dart';

/// Restarts the game to initial state
class RestartGameUseCase {
  final SpawnTileUseCase _spawnTileUseCase;

  RestartGameUseCase(this._spawnTileUseCase);

  /// Restarts the game with current board size and best score
  Future<Either<Failure, GameStateEntity>> call(
    GameStateEntity currentState,
  ) async {
    try {
      // Create empty grid
      final emptyGrid = GridEntity.empty(currentState.boardSize.size);

      // Spawn initial tiles (2 tiles)
      final spawnResult = await _spawnTileUseCase.spawnMultiple(emptyGrid, 2);

      return spawnResult.fold(
        (failure) => Left(failure),
        (gridWithTiles) {
          // Create new game state
          final newState = GameStateEntity.initial(
            boardSize: currentState.boardSize,
            bestScore: currentState.bestScore,
          ).copyWith(
            grid: gridWithTiles,
            status: GameStatus.playing,
          );

          return Right(newState);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Restarts with different board size
  Future<Either<Failure, GameStateEntity>> callWithNewSize(
    BoardSize newSize,
    int bestScore,
  ) async {
    try {
      // Create empty grid
      final emptyGrid = GridEntity.empty(newSize.size);

      // Spawn initial tiles
      final spawnResult = await _spawnTileUseCase.spawnMultiple(emptyGrid, 2);

      return spawnResult.fold(
        (failure) => Left(failure),
        (gridWithTiles) {
          final newState = GameStateEntity.initial(
            boardSize: newSize,
            bestScore: bestScore,
          ).copyWith(
            grid: gridWithTiles,
            status: GameStatus.playing,
          );

          return Right(newState);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
