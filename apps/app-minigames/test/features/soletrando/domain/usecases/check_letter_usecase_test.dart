import 'package:flutter_test/flutter_test.dart';

import 'package:app_minigames/features/soletrando/domain/entities/enums.dart';
import 'package:app_minigames/features/soletrando/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/soletrando/domain/entities/word_entity.dart';
import 'package:app_minigames/features/soletrando/domain/repositories/soletrando_repository.dart';
import 'package:app_minigames/features/soletrando/domain/usecases/check_letter_usecase.dart';

void main() {
  late CheckLetterUseCase useCase;

  setUp(() {
    useCase = CheckLetterUseCase();
  });

  // Helper to create test game state
  GameStateEntity createTestState({
    String word = 'BANANA',
    GameStatus status = GameStatus.playing,
    Set<String>? guessedLetters,
    int mistakes = 0,
  }) {
    final wordEntity = WordEntity.fromString(
      word,
      category: WordCategory.fruits,
      difficulty: GameDifficulty.medium,
    );

    return GameStateEntity.forWord(
      word: wordEntity,
      difficulty: GameDifficulty.medium,
    ).copyWith(
      guessedLetters: guessedLetters ?? {},
      mistakes: mistakes,
      status: status,
    );
  }

  group('CheckLetterUseCase', () {
    test('should mark letter as correct when letter is in word', () async {
      // Arrange
      final state = createTestState(word: 'CASA');
      final params = CheckLetterParams(currentState: state, letter: 'C');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.letters[0].isRevealed, true);
          expect(newState.guessedLetters.contains('C'), true);
          expect(newState.mistakes, 0);
        },
      );
    });

    test('should mark letter as incorrect when letter is not in word', () async {
      // Arrange
      final state = createTestState(word: 'CASA');
      final params = CheckLetterParams(currentState: state, letter: 'X');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.letters.every((l) => !l.isRevealed), true);
          expect(newState.guessedLetters.contains('X'), true);
          expect(newState.mistakes, 1);
        },
      );
    });

    test('should reveal all occurrences of repeated letters', () async {
      // Arrange
      final state = createTestState(word: 'BANANA');
      final params = CheckLetterParams(currentState: state, letter: 'A');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          // BANANA has 'A' at positions 1, 3, 5
          expect(newState.letters[1].isRevealed, true);
          expect(newState.letters[3].isRevealed, true);
          expect(newState.letters[5].isRevealed, true);
          expect(newState.correctLetters, 3);
        },
      );
    });

    test('should return ValidationFailure when game is not active', () async {
      // Arrange
      final state = createTestState(status: GameStatus.gameOver);
      final params = CheckLetterParams(currentState: state, letter: 'A');

      // Act
      final result = await useCase(params);

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

    test('should return ValidationFailure when letter already guessed', () async {
      // Arrange
      final state = createTestState(guessedLetters: {'A', 'B'});
      final params = CheckLetterParams(currentState: state, letter: 'A');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Letra já foi tentada');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when letter is invalid', () async {
      // Arrange
      final state = createTestState();
      final params = CheckLetterParams(currentState: state, letter: '1');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Letra inválida');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should change status to wordCompleted when word is complete', () async {
      // Arrange - word 'GO' with 'G' already revealed
      final state = createTestState(word: 'GO');
      // First reveal 'G'
      final params1 = CheckLetterParams(currentState: state, letter: 'G');
      final intermediateResult = await useCase(params1);

      late GameStateEntity intermediateState;
      intermediateResult.fold(
        (_) => fail('Should not fail'),
        (newState) => intermediateState = newState,
      );

      // Act - reveal 'O' to complete word
      final params2 = CheckLetterParams(currentState: intermediateState, letter: 'O');
      final result = await useCase(params2);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.isWordComplete, true);
          expect(newState.status, GameStatus.wordCompleted);
          expect(newState.wordsCompleted, 1);
        },
      );
    });

    test('should change status to gameOver when max mistakes reached', () async {
      // Arrange - difficulty allows 3 mistakes, set to 2
      final state = createTestState(mistakes: 2);
      final params = CheckLetterParams(currentState: state, letter: 'X');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.mistakes, 3);
          expect(newState.status, GameStatus.gameOver);
        },
      );
    });

    test('should add letter to guessedLetters set', () async {
      // Arrange
      final state = createTestState(guessedLetters: {'A'});
      final params = CheckLetterParams(currentState: state, letter: 'B');

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.guessedLetters.length, 2);
          expect(newState.guessedLetters.contains('A'), true);
          expect(newState.guessedLetters.contains('B'), true);
        },
      );
    });

    test('should calculate score bonus when word completed', () async {
      // Arrange
      final state = createTestState(word: 'AB', score: 100, timeRemaining: 50);

      // Reveal first letter
      final params1 = CheckLetterParams(currentState: state, letter: 'A');
      final result1 = await useCase(params1);

      late GameStateEntity intermediateState;
      result1.fold(
        (_) => fail('Should not fail'),
        (newState) => intermediateState = newState,
      );

      // Act - complete word
      final params2 = CheckLetterParams(currentState: intermediateState, letter: 'B');
      final result = await useCase(params2);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.score, greaterThan(100));
          expect(newState.wordsCompleted, 1);
        },
      );
    });
  });
}
