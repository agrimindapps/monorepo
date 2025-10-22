import 'package:app_minigames/features/game_2048/domain/entities/grid_entity.dart';
import 'package:app_minigames/features/game_2048/domain/entities/position_entity.dart';
import 'package:app_minigames/features/game_2048/domain/entities/tile_entity.dart';
import 'package:app_minigames/features/game_2048/domain/usecases/check_game_over_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CheckGameOverUseCase useCase;

  setUp(() {
    useCase = CheckGameOverUseCase();
  });

  group('CheckGameOverUseCase', () {
    test('should return false when grid has empty positions', () async {
      // Arrange - grid with some tiles
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

      // Act
      final result = await useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isGameOver) {
          expect(isGameOver, false); // Game not over - has empty spaces
        },
      );
    });

    test('should return true when no moves available', () async {
      // Arrange - full grid with no possible merges
      // [2, 4, 2, 4]
      // [4, 2, 4, 2]
      // [2, 4, 2, 4]
      // [4, 2, 4, 2]
      final tiles = <TileEntity>[];
      for (int row = 0; row < 4; row++) {
        for (int col = 0; col < 4; col++) {
          final value = (row + col) % 2 == 0 ? 2 : 4;
          tiles.add(TileEntity(
            id: '$row-$col',
            value: value,
            position: PositionEntity(row: row, col: col),
          ));
        }
      }

      final grid = GridEntity(tiles: tiles, size: 4);

      // Act
      final result = await useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isGameOver) {
          expect(isGameOver, true); // Game over - no moves possible
        },
      );
    });

    test('should detect horizontal merge possibilities', () async {
      // Arrange - full grid with horizontal merge possible
      // [2, 2, 4, 8]  <- Can merge first two
      // [4, 8, 2, 16]
      // [8, 4, 16, 2]
      // [16, 2, 8, 4]
      final tiles = [
        // First row with merge possibility
        TileEntity(
          id: '0-0',
          value: 2,
          position: const PositionEntity(row: 0, col: 0),
        ),
        TileEntity(
          id: '0-1',
          value: 2,
          position: const PositionEntity(row: 0, col: 1),
        ),
        TileEntity(
          id: '0-2',
          value: 4,
          position: const PositionEntity(row: 0, col: 2),
        ),
        TileEntity(
          id: '0-3',
          value: 8,
          position: const PositionEntity(row: 0, col: 3),
        ),
        // Other rows without merges
        TileEntity(
          id: '1-0',
          value: 4,
          position: const PositionEntity(row: 1, col: 0),
        ),
        TileEntity(
          id: '1-1',
          value: 8,
          position: const PositionEntity(row: 1, col: 1),
        ),
        TileEntity(
          id: '1-2',
          value: 2,
          position: const PositionEntity(row: 1, col: 2),
        ),
        TileEntity(
          id: '1-3',
          value: 16,
          position: const PositionEntity(row: 1, col: 3),
        ),
        TileEntity(
          id: '2-0',
          value: 8,
          position: const PositionEntity(row: 2, col: 0),
        ),
        TileEntity(
          id: '2-1',
          value: 4,
          position: const PositionEntity(row: 2, col: 1),
        ),
        TileEntity(
          id: '2-2',
          value: 16,
          position: const PositionEntity(row: 2, col: 2),
        ),
        TileEntity(
          id: '2-3',
          value: 2,
          position: const PositionEntity(row: 2, col: 3),
        ),
        TileEntity(
          id: '3-0',
          value: 16,
          position: const PositionEntity(row: 3, col: 0),
        ),
        TileEntity(
          id: '3-1',
          value: 2,
          position: const PositionEntity(row: 3, col: 1),
        ),
        TileEntity(
          id: '3-2',
          value: 8,
          position: const PositionEntity(row: 3, col: 2),
        ),
        TileEntity(
          id: '3-3',
          value: 4,
          position: const PositionEntity(row: 3, col: 3),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);

      // Act
      final result = await useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isGameOver) {
          expect(isGameOver, false); // Not game over - horizontal merge possible
        },
      );
    });

    test('should detect vertical merge possibilities', () async {
      // Arrange - full grid with vertical merge possible
      // [2, 4, 8, 16]
      // [2, 8, 4, 2]  <- First column has vertical merge
      // [4, 2, 16, 8]
      // [8, 16, 2, 4]
      final tiles = [
        // First column with merge possibility
        TileEntity(
          id: '0-0',
          value: 2,
          position: const PositionEntity(row: 0, col: 0),
        ),
        TileEntity(
          id: '1-0',
          value: 2,
          position: const PositionEntity(row: 1, col: 0),
        ),
        TileEntity(
          id: '2-0',
          value: 4,
          position: const PositionEntity(row: 2, col: 0),
        ),
        TileEntity(
          id: '3-0',
          value: 8,
          position: const PositionEntity(row: 3, col: 0),
        ),
        // Other columns without merges
        TileEntity(
          id: '0-1',
          value: 4,
          position: const PositionEntity(row: 0, col: 1),
        ),
        TileEntity(
          id: '1-1',
          value: 8,
          position: const PositionEntity(row: 1, col: 1),
        ),
        TileEntity(
          id: '2-1',
          value: 2,
          position: const PositionEntity(row: 2, col: 1),
        ),
        TileEntity(
          id: '3-1',
          value: 16,
          position: const PositionEntity(row: 3, col: 1),
        ),
        TileEntity(
          id: '0-2',
          value: 8,
          position: const PositionEntity(row: 0, col: 2),
        ),
        TileEntity(
          id: '1-2',
          value: 4,
          position: const PositionEntity(row: 1, col: 2),
        ),
        TileEntity(
          id: '2-2',
          value: 16,
          position: const PositionEntity(row: 2, col: 2),
        ),
        TileEntity(
          id: '3-2',
          value: 2,
          position: const PositionEntity(row: 3, col: 2),
        ),
        TileEntity(
          id: '0-3',
          value: 16,
          position: const PositionEntity(row: 0, col: 3),
        ),
        TileEntity(
          id: '1-3',
          value: 2,
          position: const PositionEntity(row: 1, col: 3),
        ),
        TileEntity(
          id: '2-3',
          value: 8,
          position: const PositionEntity(row: 2, col: 3),
        ),
        TileEntity(
          id: '3-3',
          value: 4,
          position: const PositionEntity(row: 3, col: 3),
        ),
      ];

      final grid = GridEntity(tiles: tiles, size: 4);

      // Act
      final result = await useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isGameOver) {
          expect(isGameOver, false); // Not game over - vertical merge possible
        },
      );
    });
  });
}
