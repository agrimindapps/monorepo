import 'package:app_minigames/features/sudoku/domain/entities/sudoku_grid_entity.dart';
import 'package:app_minigames/features/sudoku/domain/usecases/validate_move_usecase.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ValidateMoveUseCase useCase;

  setUp(() {
    useCase = ValidateMoveUseCase();
  });

  group('ValidateMoveUseCase', () {
    test('should return success for valid move', () {
      // Arrange - Create grid with a valid placement
      final grid = SudokuGridEntity.empty();

      // Act
      final result = useCase(grid: grid, row: 0, col: 0, value: 5);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isValid) => expect(isValid, true),
      );
    });

    test('should return ValidationFailure when position is out of bounds', () {
      // Arrange
      final grid = SudokuGridEntity.empty();

      // Act
      final result = useCase(grid: grid, row: 10, col: 0, value: 5);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('out of bounds'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when value is invalid', () {
      // Arrange
      final grid = SudokuGridEntity.empty();

      // Act - value 0
      final result1 = useCase(grid: grid, row: 0, col: 0, value: 0);

      // Assert
      expect(result1.isLeft(), true);
      result1.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('between 1 and 9'));
        },
        (_) => fail('Should not return success'),
      );

      // Act - value 10
      final result2 = useCase(grid: grid, row: 0, col: 0, value: 10);

      // Assert
      expect(result2.isLeft(), true);
    });

    test('should return ValidationFailure when cell is fixed', () {
      // Arrange - Create grid with fixed cell
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0][0] = 5; // Fixed cell
      final grid = SudokuGridEntity.fromArray(array);

      // Act
      final result = useCase(grid: grid, row: 0, col: 0, value: 3);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('fixed cell'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when number conflicts in row', () {
      // Arrange - Create grid with number in same row
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0][0] = 5; // Fixed cell with value 5
      var grid = SudokuGridEntity.fromArray(array);

      // Make cell [0][1] editable
      final cell = grid.getCell(0, 1);
      final editableCell = cell.copyWith(isFixed: false);
      grid = grid.updateCell(editableCell);

      // Act - Try to place 5 in same row
      final result = useCase(grid: grid, row: 0, col: 1, value: 5);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('conflicts'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when number conflicts in column', () {
      // Arrange
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0][0] = 5; // Fixed cell with value 5
      var grid = SudokuGridEntity.fromArray(array);

      // Make cell [1][0] editable
      final cell = grid.getCell(1, 0);
      final editableCell = cell.copyWith(isFixed: false);
      grid = grid.updateCell(editableCell);

      // Act - Try to place 5 in same column
      final result = useCase(grid: grid, row: 1, col: 0, value: 5);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('conflicts'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when number conflicts in 3x3 block', () {
      // Arrange
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0][0] = 5; // Fixed cell with value 5 in top-left block
      var grid = SudokuGridEntity.fromArray(array);

      // Make cell [1][1] editable (same block)
      final cell = grid.getCell(1, 1);
      final editableCell = cell.copyWith(isFixed: false);
      grid = grid.updateCell(editableCell);

      // Act - Try to place 5 in same block
      final result = useCase(grid: grid, row: 1, col: 1, value: 5);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('conflicts'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return success when placing number in different row, column, and block', () {
      // Arrange
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0][0] = 5; // Fixed cell with value 5
      var grid = SudokuGridEntity.fromArray(array);

      // Make cell [4][4] editable (different row, col, and block)
      final cell = grid.getCell(4, 4);
      final editableCell = cell.copyWith(isFixed: false);
      grid = grid.updateCell(editableCell);

      // Act - Place 5 in middle cell (different block)
      final result = useCase(grid: grid, row: 4, col: 4, value: 5);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isValid) => expect(isValid, true),
      );
    });
  });
}
