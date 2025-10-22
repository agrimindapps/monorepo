import 'package:flutter_test/flutter_test.dart';

import 'package:app_minigames/features/soletrando/domain/entities/enums.dart';
import 'package:app_minigames/features/soletrando/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/soletrando/domain/entities/word_entity.dart';
import 'package:app_minigames/features/soletrando/domain/repositories/soletrando_repository.dart';
import 'package:app_minigames/features/soletrando/domain/usecases/reveal_hint_usecase.dart';

void main() {
  late RevealHintUseCase useCase;

  setUp(() {
    useCase = RevealHintUseCase();
  });

  // Helper to create test game state
  GameStateEntity createTestState({
    String word = 'CASA',
    GameStatus status = GameStatus.playing,
    int hintsUsed = 0,
    GameDifficulty difficulty = GameDifficulty.medium,
  }) {
    final wordEntity = WordEntity.fromString(
      word,
      category: WordCategory.fruits,
      difficulty: difficulty,
    );

    return GameStateEntity.forWord(
      word: wordEntity,
      difficulty: difficulty,
    ).copyWith(
      hintsUsed: hintsUsed,
      status: status,
    );
  }

  group('RevealHintUseCase', () {
    test('should reveal a random pending letter', () async {
      // Arrange
      final state = createTestState(word: 'CASA');

      // Act
      final result = await useCase(state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.correctLetters, greaterThan(0));
          expect(newState.hintsUsed, 1);
        },
      );
    });

    test('should increment hintsUsed counter', () async {
      // Arrange
      final state = createTestState(hintsUsed: 1);

      // Act
      final result = await useCase(state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.hintsUsed, 2);
        },
      );
    });

    test('should add revealed letter to guessedLetters', () async {
      // Arrange
      final state = createTestState(word: 'CASA');

      // Act
      final result = await useCase(state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.guessedLetters.length, greaterThan(0));
        },
      );
    });

    test('should return ValidationFailure when game is not active', () async {
      // Arrange
      final state = createTestState(status: GameStatus.gameOver);

      // Act
      final result = await useCase(state);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Jogo não está ativo');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when no hints available', () async {
      // Arrange - medium difficulty has 3 hints
      final state = createTestState(
        hintsUsed: 3,
        difficulty: GameDifficulty.medium,
      );

      // Act
      final result = await useCase(state);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Sem dicas disponíveis');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should respect difficulty hint limits', () async {
      // Arrange - hard difficulty has only 1 hint
      final state = createTestState(
        hintsUsed: 0,
        difficulty: GameDifficulty.hard,
      );

      // Act - use first hint
      final result1 = await useCase(state);

      late GameStateEntity stateAfterFirstHint;
      result1.fold(
        (_) => fail('First hint should succeed'),
        (newState) => stateAfterFirstHint = newState,
      );

      // Act - try to use second hint
      final result2 = await useCase(stateAfterFirstHint);

      // Assert
      expect(result2.isLeft(), true);
      result2.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should not allow hint beyond limit'),
      );
    });
  });
}
