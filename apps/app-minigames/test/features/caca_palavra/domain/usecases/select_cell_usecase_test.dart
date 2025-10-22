import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/enums.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/game_state.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/position.dart';
import 'package:app_minigames/features/caca_palavra/domain/usecases/select_cell_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SelectCellUseCase useCase;

  setUp(() {
    useCase = SelectCellUseCase();
  });

  group('SelectCellUseCase', () {
    final initialState = GameState.initial(difficulty: GameDifficulty.easy);

    test('should add first cell to empty selection', () {
      // Act
      final result = useCase(
        currentState: initialState,
        row: 0,
        col: 0,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (state) {
          expect(state.selectedPositions.length, 1);
          expect(state.selectedPositions.first, const Position(0, 0));
        },
      );
    });

    test('should add adjacent cell to selection', () {
      // Arrange
      final stateWithSelection = initialState.copyWith(
        selectedPositions: [const Position(0, 0)],
      );

      // Act - Adjacent horizontal
      final result = useCase(
        currentState: stateWithSelection,
        row: 0,
        col: 1,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (state) {
          expect(state.selectedPositions.length, 2);
          expect(state.selectedPositions.last, const Position(0, 1));
        },
      );
    });

    test('should maintain direction alignment', () {
      // Arrange - Horizontal selection
      final stateWithSelection = initialState.copyWith(
        selectedPositions: [
          const Position(0, 0),
          const Position(0, 1),
        ],
      );

      // Act - Continue horizontal
      final result = useCase(
        currentState: stateWithSelection,
        row: 0,
        col: 2,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (state) {
          expect(state.selectedPositions.length, 3);
          expect(state.selectedPositions.last, const Position(0, 2));
        },
      );
    });

    test('should clear selection when direction changes', () {
      // Arrange - Horizontal selection
      final stateWithSelection = initialState.copyWith(
        selectedPositions: [
          const Position(0, 0),
          const Position(0, 1),
        ],
      );

      // Act - Try to change direction (vertical)
      final result = useCase(
        currentState: stateWithSelection,
        row: 1,
        col: 1,
      );

      // Assert - Should clear and start new selection
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (state) {
          expect(state.selectedPositions.length, 1);
          expect(state.selectedPositions.first, const Position(1, 1));
        },
      );
    });

    test('should remove last position when tapping it again', () {
      // Arrange
      final stateWithSelection = initialState.copyWith(
        selectedPositions: [
          const Position(0, 0),
          const Position(0, 1),
          const Position(0, 2),
        ],
      );

      // Act - Tap last position again
      final result = useCase(
        currentState: stateWithSelection,
        row: 0,
        col: 2,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (state) {
          expect(state.selectedPositions.length, 2);
          expect(state.selectedPositions.last, const Position(0, 1));
        },
      );
    });

    test('should clear all when tapping non-last selected position', () {
      // Arrange
      final stateWithSelection = initialState.copyWith(
        selectedPositions: [
          const Position(0, 0),
          const Position(0, 1),
          const Position(0, 2),
        ],
      );

      // Act - Tap first position (not last)
      final result = useCase(
        currentState: stateWithSelection,
        row: 0,
        col: 0,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (state) {
          expect(state.selectedPositions.isEmpty, true);
        },
      );
    });

    test('should return failure for invalid position', () {
      // Act - Out of bounds
      final result = useCase(
        currentState: initialState,
        row: -1,
        col: 0,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Invalid grid position'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when game is not playing', () {
      // Arrange - Completed game
      final completedState = initialState.copyWith(
        status: GameStatus.completed,
      );

      // Act
      final result = useCase(
        currentState: completedState,
        row: 0,
        col: 0,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('not in playing state'));
        },
        (_) => fail('Should not return success'),
      );
    });
  });
}
