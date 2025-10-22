import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/enums.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/game_state.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/position.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/word_entity.dart';
import 'package:app_minigames/features/caca_palavra/domain/usecases/toggle_word_highlight_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ToggleWordHighlightUseCase useCase;

  setUp(() {
    useCase = ToggleWordHighlightUseCase();
  });

  group('ToggleWordHighlightUseCase', () {
    final word1 = WordEntity(
      text: 'WORD1',
      direction: WordDirection.horizontal,
      positions: [const Position(0, 0), const Position(0, 1)],
    );

    final word2 = WordEntity(
      text: 'WORD2',
      direction: WordDirection.vertical,
      positions: [const Position(0, 0), const Position(1, 0)],
    );

    test('should toggle highlight on target word', () {
      // Arrange
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [word1, word2],
        selectedPositions: [],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act - Highlight first word
      final result = useCase(currentState: state, wordIndex: 0);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.words[0].isHighlighted, true);
          expect(newState.words[1].isHighlighted, false);
        },
      );
    });

    test('should remove other highlights when highlighting new word', () {
      // Arrange - First word already highlighted
      final highlightedWord1 = word1.copyWith(isHighlighted: true);
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [highlightedWord1, word2],
        selectedPositions: [],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act - Highlight second word
      final result = useCase(currentState: state, wordIndex: 1);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.words[0].isHighlighted, false);
          expect(newState.words[1].isHighlighted, true);
        },
      );
    });

    test('should toggle off when tapping highlighted word', () {
      // Arrange - Word already highlighted
      final highlightedWord = word1.copyWith(isHighlighted: true);
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [highlightedWord, word2],
        selectedPositions: [],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act - Tap same word again
      final result = useCase(currentState: state, wordIndex: 0);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.words[0].isHighlighted, false);
        },
      );
    });

    test('should not highlight found words', () {
      // Arrange - Word already found
      final foundWord = word1.copyWith(isFound: true);
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [foundWord, word2],
        selectedPositions: [],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 1,
      );

      // Act - Try to highlight found word
      final result = useCase(currentState: state, wordIndex: 0);

      // Assert - Should return state unchanged
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.words[0].isHighlighted, false);
          expect(newState, equals(state));
        },
      );
    });

    test('should return failure for invalid word index', () {
      // Arrange
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [word1, word2],
        selectedPositions: [],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act - Invalid index
      final result = useCase(currentState: state, wordIndex: 10);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Invalid word index'));
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure for negative index', () {
      // Arrange
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [word1, word2],
        selectedPositions: [],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act
      final result = useCase(currentState: state, wordIndex: -1);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should not return success'),
      );
    });
  });
}
