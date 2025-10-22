import 'package:app_minigames/features/sudoku/domain/entities/sudoku_cell_entity.dart';
import 'package:app_minigames/features/sudoku/domain/entities/sudoku_grid_entity.dart';
import 'package:app_minigames/features/sudoku/domain/usecases/check_completion_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CheckCompletionUseCase useCase;

  setUp(() {
    useCase = CheckCompletionUseCase();
  });

  group('CheckCompletionUseCase', () {
    test('should return false for empty grid', () {
      // Arrange
      final grid = SudokuGridEntity.empty();

      // Act
      final result = useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isComplete) => expect(isComplete, false),
      );
    });

    test('should return false for partially filled grid', () {
      // Arrange - Fill only first row
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0] = [1, 2, 3, 4, 5, 6, 7, 8, 9];
      final grid = SudokuGridEntity.fromArray(array);

      // Act
      final result = useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isComplete) => expect(isComplete, false),
      );
    });

    test('should return true for completely filled valid grid', () {
      // Arrange - Create a valid completed sudoku
      final array = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
      ];
      final grid = SudokuGridEntity.fromArray(array);

      // Act
      final result = useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isComplete) => expect(isComplete, true),
      );
    });

    test('should return false for completely filled but invalid grid', () {
      // Arrange - Create grid with conflicts (duplicate in row)
      final array = [
        [1, 1, 3, 4, 5, 6, 7, 8, 9], // Duplicate 1
        [2, 3, 4, 5, 6, 7, 8, 9, 1],
        [3, 4, 5, 6, 7, 8, 9, 1, 2],
        [4, 5, 6, 7, 8, 9, 1, 2, 3],
        [5, 6, 7, 8, 9, 1, 2, 3, 4],
        [6, 7, 8, 9, 1, 2, 3, 4, 5],
        [7, 8, 9, 1, 2, 3, 4, 5, 6],
        [8, 9, 1, 2, 3, 4, 5, 6, 7],
        [9, 1, 2, 3, 4, 5, 6, 7, 8],
      ];
      var grid = SudokuGridEntity.fromArray(array);

      // Mark conflicts manually since UpdateConflictsUseCase is separate
      final cell0 = grid.getCell(0, 0).copyWith(hasConflict: true);
      final cell1 = grid.getCell(0, 1).copyWith(hasConflict: true);
      grid = grid.updateCell(cell0);
      grid = grid.updateCell(cell1);

      // Act
      final result = useCase(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (isComplete) => expect(isComplete, false),
      );
    });

    test('should calculate progress correctly', () {
      // Arrange - Fill 40 cells
      var grid = SudokuGridEntity.empty();
      for (int i = 0; i < 40; i++) {
        final row = i ~/ 9;
        final col = i % 9;
        final cell = grid.getCell(row, col).copyWith(value: 1);
        grid = grid.updateCell(cell);
      }

      // Act
      final result = useCase.getProgress(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (progress) {
          expect(progress, closeTo(40 / 81, 0.01));
        },
      );
    });

    test('should return 0 progress for empty grid', () {
      // Arrange
      final grid = SudokuGridEntity.empty();

      // Act
      final result = useCase.getProgress(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (progress) => expect(progress, 0.0),
      );
    });

    test('should return 1.0 progress for complete grid', () {
      // Arrange - Fill all cells
      final array = List.generate(9, (i) => List.generate(9, (j) => 1));
      final grid = SudokuGridEntity.fromArray(array);

      // Act
      final result = useCase.getProgress(grid);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (progress) => expect(progress, 1.0),
      );
    });
  });
}
