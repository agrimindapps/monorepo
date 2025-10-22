import 'package:app_minigames/features/game_2048/domain/entities/enums.dart';
import 'package:app_minigames/features/game_2048/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/game_2048/domain/entities/grid_entity.dart';
import 'package:app_minigames/features/game_2048/domain/entities/position_entity.dart';
import 'package:app_minigames/features/game_2048/domain/entities/tile_entity.dart';
import 'package:app_minigames/features/game_2048/domain/usecases/move_tiles_usecase.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MoveTilesUseCase useCase;

  setUp(() {
    useCase = MoveTilesUseCase();
  });

  group('MoveTilesUseCase', () {
    test('should move tiles left correctly', () async {
      // Arrange: Create grid with tiles that can move left
      // [2, 0, 0, 0]
      // [0, 2, 0, 0]
      // [0, 0, 2, 0]
      // [0, 0, 0, 2]
      final tiles = [
        TileEntity(
          id: '1',
          value: 2,
          position: const PositionEntity(row: 0, col: 0),
        ),
        TileEntity(
          id: '2',
          value: 2,
          position: const PositionEntity(row: 1, col: 1),
        ),
        TileEntity(
          id: '3',
          value: 2,
          position: const PositionEntity(row: 2, col: 2),
        ),
        TileEntity(
          id: '4',
          value: 2,
          position: const PositionEntity(row: 3, col: 3),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);
      final state = GameStateEntity.initial(boardSize: BoardSize.size4x4)
          .copyWith(grid: grid, status: GameStatus.playing);

      // Act
      final result = await useCase(state, Direction.left);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          // All tiles should be in column 0
          for (final tile in newState.grid.tiles) {
            expect(tile.position.col, 0);
          }
          expect(newState.moves, 1);
        },
      );
    });

    test('should move tiles right correctly', () async {
      // Arrange: [2, 0, 0, 0] -> [0, 0, 0, 2]
      final tiles = [
        TileEntity(
          id: '1',
          value: 2,
          position: const PositionEntity(row: 0, col: 0),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);
      final state = GameStateEntity.initial(boardSize: BoardSize.size4x4)
          .copyWith(grid: grid, status: GameStatus.playing);

      // Act
      final result = await useCase(state, Direction.right);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.grid.tiles.first.position.col, 3);
          expect(newState.moves, 1);
        },
      );
    });

    test('should move tiles up correctly', () async {
      // Arrange: Vertical movement
      final tiles = [
        TileEntity(
          id: '1',
          value: 2,
          position: const PositionEntity(row: 3, col: 0),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);
      final state = GameStateEntity.initial(boardSize: BoardSize.size4x4)
          .copyWith(grid: grid, status: GameStatus.playing);

      // Act
      final result = await useCase(state, Direction.up);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.grid.tiles.first.position.row, 0);
          expect(newState.moves, 1);
        },
      );
    });

    test('should move tiles down correctly', () async {
      // Arrange
      final tiles = [
        TileEntity(
          id: '1',
          value: 2,
          position: const PositionEntity(row: 0, col: 0),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);
      final state = GameStateEntity.initial(boardSize: BoardSize.size4x4)
          .copyWith(grid: grid, status: GameStatus.playing);

      // Act
      final result = await useCase(state, Direction.down);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.grid.tiles.first.position.row, 3);
          expect(newState.moves, 1);
        },
      );
    });

    test('should merge tiles with same value', () async {
      // Arrange: [2, 2, 0, 0] -> [4, 0, 0, 0]
      final tiles = [
        TileEntity(
          id: '1',
          value: 2,
          position: const PositionEntity(row: 0, col: 0),
        ),
        TileEntity(
          id: '2',
          value: 2,
          position: const PositionEntity(row: 0, col: 1),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);
      final state = GameStateEntity.initial(boardSize: BoardSize.size4x4)
          .copyWith(grid: grid, status: GameStatus.playing);

      // Act
      final result = await useCase(state, Direction.left);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.grid.tiles.length, 1);
          expect(newState.grid.tiles.first.value, 4);
          expect(newState.score, 4); // Score increases by merged value
        },
      );
    });

    test('should update score after merge', () async {
      // Arrange: Multiple merges
      final tiles = [
        TileEntity(
          id: '1',
          value: 4,
          position: const PositionEntity(row: 0, col: 0),
        ),
        TileEntity(
          id: '2',
          value: 4,
          position: const PositionEntity(row: 0, col: 1),
        ),
        TileEntity(
          id: '3',
          value: 8,
          position: const PositionEntity(row: 0, col: 2),
        ),
        TileEntity(
          id: '4',
          value: 8,
          position: const PositionEntity(row: 0, col: 3),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);
      final state = GameStateEntity.initial(boardSize: BoardSize.size4x4)
          .copyWith(grid: grid, status: GameStatus.playing);

      // Act
      final result = await useCase(state, Direction.left);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.grid.tiles.length, 2);
          expect(newState.score, 24); // 8 + 16 = 24
        },
      );
    });

    test('should return ValidationFailure when game is not playing', () async {
      // Arrange
      final grid = GridEntity.empty(4);
      final state = GameStateEntity.initial(boardSize: BoardSize.size4x4)
          .copyWith(grid: grid, status: GameStatus.gameOver);

      // Act
      final result = await useCase(state, Direction.left);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Cannot move tiles when game is not playing',
          );
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should not move when no valid moves', () async {
      // Arrange: Tiles already at left edge
      final tiles = [
        TileEntity(
          id: '1',
          value: 2,
          position: const PositionEntity(row: 0, col: 0),
        ),
        TileEntity(
          id: '2',
          value: 4,
          position: const PositionEntity(row: 0, col: 1),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);
      final state = GameStateEntity.initial(boardSize: BoardSize.size4x4)
          .copyWith(grid: grid, status: GameStatus.playing);

      // Act
      final result = await useCase(state, Direction.left);

      // Assert - state should remain unchanged
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.moves, 0); // No move counted
          expect(newState.grid.tiles.length, state.grid.tiles.length);
        },
      );
    });
  });
}
