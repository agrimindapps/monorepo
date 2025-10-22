import 'package:app_minigames/features/sudoku/domain/entities/enums.dart';
import 'package:app_minigames/features/sudoku/domain/usecases/generate_puzzle_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GeneratePuzzleUseCase useCase;

  setUp(() {
    useCase = GeneratePuzzleUseCase();
  });

  group('GeneratePuzzleUseCase', () {
    test('should generate easy puzzle with correct number of clues', () async {
      // Act
      final result = await useCase(GameDifficulty.easy);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (grid) {
          final fixedCells = grid.getFixedCells();
          expect(fixedCells.length, 51); // 81 - 30 = 51 clues
          expect(grid.emptyCount, 30);
        },
      );
    });

    test('should generate medium puzzle with correct number of clues', () async {
      // Act
      final result = await useCase(GameDifficulty.medium);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (grid) {
          final fixedCells = grid.getFixedCells();
          expect(fixedCells.length, 36); // 81 - 45 = 36 clues
          expect(grid.emptyCount, 45);
        },
      );
    });

    test('should generate hard puzzle with correct number of clues', () async {
      // Act
      final result = await useCase(GameDifficulty.hard);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (grid) {
          final fixedCells = grid.getFixedCells();
          expect(fixedCells.length, 26); // 81 - 55 = 26 clues
          expect(grid.emptyCount, 55);
        },
      );
    });

    test('should generate valid puzzle with no conflicts', () async {
      // Act
      final result = await useCase(GameDifficulty.medium);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (grid) {
          // Check all fixed cells have no conflicts
          for (final cell in grid.getFixedCells()) {
            expect(cell.hasConflict, false);
          }

          // Validate all rows
          for (int row = 0; row < 9; row++) {
            final rowCells = grid.getRow(row);
            final values = rowCells
                .where((c) => !c.isEmpty)
                .map((c) => c.value)
                .toList();
            // No duplicates
            expect(values.toSet().length, values.length);
          }

          // Validate all columns
          for (int col = 0; col < 9; col++) {
            final colCells = grid.getColumn(col);
            final values = colCells
                .where((c) => !c.isEmpty)
                .map((c) => c.value)
                .toList();
            expect(values.toSet().length, values.length);
          }

          // Validate all blocks
          for (int block = 0; block < 9; block++) {
            final blockCells = grid.getBlock(block);
            final values = blockCells
                .where((c) => !c.isEmpty)
                .map((c) => c.value)
                .toList();
            expect(values.toSet().length, values.length);
          }
        },
      );
    });

    test('should mark given cells as fixed', () async {
      // Act
      final result = await useCase(GameDifficulty.easy);

      // Assert
      result.fold(
        (_) => fail('Should not return failure'),
        (grid) {
          for (final cell in grid.cells) {
            if (!cell.isEmpty) {
              expect(cell.isFixed, true);
              expect(cell.isEditable, false);
            } else {
              expect(cell.isFixed, false);
              expect(cell.isEditable, true);
            }
          }
        },
      );
    });

    test('should generate different puzzles on multiple calls', () async {
      // Act
      final result1 = await useCase(GameDifficulty.medium);
      final result2 = await useCase(GameDifficulty.medium);

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      result1.fold(
        (_) => fail('Should not return failure'),
        (grid1) {
          result2.fold(
            (_) => fail('Should not return failure'),
            (grid2) {
              // Convert to arrays for comparison
              final array1 = grid1.toArray();
              final array2 = grid2.toArray();

              // Puzzles should be different (very unlikely to be identical)
              bool isDifferent = false;
              for (int i = 0; i < 9; i++) {
                for (int j = 0; j < 9; j++) {
                  if (array1[i][j] != array2[i][j]) {
                    isDifferent = true;
                    break;
                  }
                }
                if (isDifferent) break;
              }

              expect(isDifferent, true);
            },
          );
        },
      );
    });
  });
}
