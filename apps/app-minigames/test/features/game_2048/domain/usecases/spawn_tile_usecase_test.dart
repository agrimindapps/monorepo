import 'package:app_minigames/features/game_2048/domain/entities/grid_entity.dart';
import 'package:app_minigames/features/game_2048/domain/entities/position_entity.dart';
import 'package:app_minigames/features/game_2048/domain/entities/tile_entity.dart';
import 'package:app_minigames/features/game_2048/domain/usecases/spawn_tile_usecase.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SpawnTileUseCase useCase;

  setUp(() {
    useCase = SpawnTileUseCase();
  });

  group('SpawnTileUseCase', () {
    test('should spawn tile in empty cell', () async {
      // Arrange
      final grid = GridEntity.empty(4);

      // Act
      final result = await useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newGrid) {
          expect(newGrid.tiles.length, 1);
          expect(newGrid.tiles.first.value, isIn([2, 4]));
        },
      );
    });

    test('should spawn 2 or 4 with correct probability', () async {
      // Arrange
      final grid = GridEntity.empty(4);
      final valueCounts = <int, int>{2: 0, 4: 0};

      // Act - spawn many tiles to test probability
      for (int i = 0; i < 100; i++) {
        final result = await useCase(grid);
        result.fold(
          (_) => fail('Should not fail'),
          (newGrid) {
            final value = newGrid.tiles.first.value;
            valueCounts[value] = (valueCounts[value] ?? 0) + 1;
          },
        );
      }

      // Assert - roughly 90% should be 2, 10% should be 4
      expect(valueCounts[2]! > valueCounts[4]!, true);
      expect(valueCounts[2]! > 70, true); // At least 70% are 2s
      expect(valueCounts[4]! > 5, true); // At least 5% are 4s
    });

    test('should return failure when grid is full', () async {
      // Arrange - create full grid
      final tiles = <TileEntity>[];
      for (int row = 0; row < 4; row++) {
        for (int col = 0; col < 4; col++) {
          tiles.add(TileEntity(
            id: '$row-$col',
            value: 2,
            position: PositionEntity(row: row, col: col),
          ));
        }
      }

      final grid = GridEntity(tiles: tiles, size: 4);

      // Act
      final result = await useCase(grid);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'No empty positions to spawn tile');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should spawn multiple tiles successfully', () async {
      // Arrange
      final grid = GridEntity.empty(4);

      // Act
      final result = await useCase.spawnMultiple(grid, 3);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newGrid) {
          expect(newGrid.tiles.length, 3);
        },
      );
    });

    test('should return failure when spawn count is less than 1', () async {
      // Arrange
      final grid = GridEntity.empty(4);

      // Act
      final result = await useCase.spawnMultiple(grid, 0);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Count must be at least 1');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should fail spawnMultiple when grid becomes full', () async {
      // Arrange - grid with only 2 empty cells
      final tiles = <TileEntity>[];
      for (int row = 0; row < 4; row++) {
        for (int col = 0; col < 4; col++) {
          if (row == 0 && col < 2) {
            // Leave first 2 cells empty
            continue;
          }
          tiles.add(TileEntity(
            id: '$row-$col',
            value: 2,
            position: PositionEntity(row: row, col: col),
          ));
        }
      }

      final grid = GridEntity(tiles: tiles, size: 4);

      // Act - try to spawn 3 tiles when only 2 spaces available
      final result = await useCase.spawnMultiple(grid, 3);

      // Assert - should fail on third spawn
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should not return success'),
      );
    });
  });
}
