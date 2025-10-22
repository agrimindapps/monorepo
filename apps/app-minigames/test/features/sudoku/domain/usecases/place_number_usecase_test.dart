import 'package:app_minigames/features/sudoku/domain/entities/sudoku_grid_entity.dart';
import 'package:app_minigames/features/sudoku/domain/usecases/place_number_usecase.dart';
import 'package:app_minigames/features/sudoku/domain/usecases/update_conflicts_usecase.dart';
import 'package:app_minigames/features/sudoku/domain/usecases/validate_move_usecase.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PlaceNumberUseCase useCase;
  late ValidateMoveUseCase validateMoveUseCase;
  late UpdateConflictsUseCase updateConflictsUseCase;

  setUp(() {
    validateMoveUseCase = ValidateMoveUseCase();
    updateConflictsUseCase = UpdateConflictsUseCase();
    useCase = PlaceNumberUseCase(validateMoveUseCase, updateConflictsUseCase);
  });

  group('PlaceNumberUseCase', () {
    test('should place number successfully on empty editable cell', () {
      // Arrange
      final grid = SudokuGridEntity.empty();

      // Act
      final result = useCase(grid: grid, row: 0, col: 0, value: 5);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (updatedGrid) {
          final cell = updatedGrid.getCell(0, 0);
          expect(cell.value, 5);
          expect(cell.isFixed, false);
          expect(cell.hasConflict, false);
        },
      );
    });

    test('should clear notes when placing number', () {
      // Arrange
      var grid = SudokuGridEntity.empty();
      final cell = grid.getCell(0, 0);
      final cellWithNotes = cell.addNote(1).addNote(2).addNote(3);
      grid = grid.updateCell(cellWithNotes);

      // Act
      final result = useCase(grid: grid, row: 0, col: 0, value: 5);

      // Assert
      result.fold(
        (_) => fail('Should not return failure'),
        (updatedGrid) {
          final updatedCell = updatedGrid.getCell(0, 0);
          expect(updatedCell.value, 5);
          expect(updatedCell.notes.isEmpty, true);
        },
      );
    });

    test('should return ValidationFailure when placing on fixed cell', () {
      // Arrange
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0][0] = 5;
      final grid = SudokuGridEntity.fromArray(array);

      // Act
      final result = useCase(grid: grid, row: 0, col: 0, value: 3);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when move creates conflict', () {
      // Arrange
      final array = List.generate(9, (_) => List.filled(9, 0));
      array[0][0] = 5;
      var grid = SudokuGridEntity.fromArray(array);

      // Make adjacent cell editable
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
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should update conflicts after placing number', () {
      // Arrange - Create grid with potential conflict
      final array = List.generate(9, (_) => List.filled(9, 0));
      var grid = SudokuGridEntity.fromArray(array);

      // Place first number
      var result = useCase(grid: grid, row: 0, col: 0, value: 5);
      grid = result.fold((_) => grid, (g) => g);

      // Place second number (valid)
      result = useCase(grid: grid, row: 1, col: 1, value: 3);

      // Assert
      result.fold(
        (_) => fail('Should not return failure'),
        (updatedGrid) {
          // Check that conflicts were updated
          expect(updatedGrid.isValid, true);
        },
      );
    });

    test('should handle placing same number in different blocks', () {
      // Arrange
      var grid = SudokuGridEntity.empty();

      // Act - Place 5 in different blocks
      var result1 = useCase(grid: grid, row: 0, col: 0, value: 5);
      grid = result1.fold((_) => grid, (g) => g);

      var result2 = useCase(grid: grid, row: 4, col: 4, value: 5);
      grid = result2.fold((_) => grid, (g) => g);

      var result3 = useCase(grid: grid, row: 6, col: 6, value: 5);

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      expect(result3.isRight(), true);

      result3.fold(
        (_) => fail('Should not return failure'),
        (updatedGrid) {
          expect(updatedGrid.getCell(0, 0).value, 5);
          expect(updatedGrid.getCell(4, 4).value, 5);
          expect(updatedGrid.getCell(6, 6).value, 5);
          expect(updatedGrid.isValid, true);
        },
      );
    });
  });
}
