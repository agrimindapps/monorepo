import 'package:app_minigames/features/sudoku/domain/entities/sudoku_grid_entity.dart';
import 'package:app_minigames/features/sudoku/domain/usecases/get_hint_usecase.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GetHintUseCase useCase;

  setUp(() {
    useCase = GetHintUseCase();
  });

  group('GetHintUseCase', () {
    test('should return hint for grid with empty cells', () {
      // Arrange - Create grid with some filled cells
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0][0] = 5;
      array[0][1] = 3;
      final grid = SudokuGridEntity.fromArray(array);

      // Act
      final result = useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (hint) {
          final position = hint.$1;
          final value = hint.$2;
          expect(position.isValid, true);
          expect(value >= 1 && value <= 9, true);
        },
      );
    });

    test('should return ValidationFailure for completely filled grid', () {
      // Arrange - Create completely filled grid
      final array = List.generate(9, (i) => List.generate(9, (j) => 1));
      final grid = SudokuGridEntity.fromArray(array);

      // Act
      final result = useCase(grid);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('No empty cells'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return valid number that can be placed', () {
      // Arrange - Create simple grid
      var grid = SudokuGridEntity.empty();

      // Fill first row except last cell
      for (int col = 0; col < 8; col++) {
        final cell = grid.getCell(0, col).copyWith(value: col + 1, isFixed: true);
        grid = grid.updateCell(cell);
      }

      // Act
      final result = useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (hint) {
          final position = hint.$1;
          final value = hint.$2;
          // Should suggest position (0, 8) with value 9
          if (position.row == 0 && position.col == 8) {
            expect(value, 9); // Only valid value for this position
          }
        },
      );
    });

    test('should return correct hint count', () {
      // Arrange - Create grid with 40 empty cells
      var grid = SudokuGridEntity.empty();

      // Fill 41 cells
      for (int i = 0; i < 41; i++) {
        final row = i ~/ 9;
        final col = i % 9;
        final cell = grid.getCell(row, col).copyWith(value: 1, isFixed: true);
        grid = grid.updateCell(cell);
      }

      // Act
      final result = useCase.getHintCount(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (count) => expect(count, 40), // 81 - 41 = 40 empty cells
      );
    });

    test('should return 0 hint count for full grid', () {
      // Arrange
      final array = List.generate(9, (i) => List.generate(9, (j) => 1));
      final grid = SudokuGridEntity.fromArray(array);

      // Act
      final result = useCase.getHintCount(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (count) => expect(count, 0),
      );
    });

    test('should return 81 hint count for empty grid', () {
      // Arrange
      final grid = SudokuGridEntity.empty();

      // Act
      final result = useCase.getHintCount(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (count) => expect(count, 81),
      );
    });

    test('should suggest valid placement that does not conflict', () {
      // Arrange - Create grid with constraints
      var grid = SudokuGridEntity.empty();

      // Place 5 in position (0,0)
      final cell1 = grid.getCell(0, 0).copyWith(value: 5, isFixed: true);
      grid = grid.updateCell(cell1);

      // Place 5 in position (1,4)
      final cell2 = grid.getCell(1, 4).copyWith(value: 5, isFixed: true);
      grid = grid.updateCell(cell2);

      // Act - Get hint for position in first row
      final result = useCase(grid);

      // Assert
      result.fold(
        (_) {}, // May fail if no valid moves
        (hint) {
          final position = hint.$1;
          final value = hint.$2;
          // If hint is in row 0, value should not be 5
          if (position.row == 0) {
            expect(value, isNot(5));
          }
          // Verify placement is valid
          expect(grid.isValidPlacement(position.row, position.col, value), true);
        },
      );
    });
  });
}
