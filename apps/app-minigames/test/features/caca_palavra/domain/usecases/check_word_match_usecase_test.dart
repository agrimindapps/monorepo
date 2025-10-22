import 'package:app_minigames/features/caca_palavra/domain/entities/enums.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/game_state.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/position.dart';
import 'package:app_minigames/features/caca_palavra/domain/entities/word_entity.dart';
import 'package:app_minigames/features/caca_palavra/domain/usecases/check_word_match_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CheckWordMatchUseCase useCase;

  setUp(() {
    useCase = CheckWordMatchUseCase();
  });

  group('CheckWordMatchUseCase', () {
    final testWord = WordEntity(
      text: 'TEST',
      direction: WordDirection.horizontal,
      positions: [
        const Position(0, 0),
        const Position(0, 1),
        const Position(0, 2),
        const Position(0, 3),
      ],
    );

    test('should mark word as found when positions match', () {
      // Arrange
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [testWord],
        selectedPositions: [
          const Position(0, 0),
          const Position(0, 1),
          const Position(0, 2),
          const Position(0, 3),
        ],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act
      final result = useCase(currentState: state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.foundWordsCount, 1);
          expect(newState.words.first.isFound, true);
          expect(newState.selectedPositions.isEmpty, true);
        },
      );
    });

    test('should match word in reverse direction', () {
      // Arrange
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [testWord],
        selectedPositions: [
          const Position(0, 3),
          const Position(0, 2),
          const Position(0, 1),
          const Position(0, 0),
        ],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act
      final result = useCase(currentState: state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.foundWordsCount, 1);
          expect(newState.words.first.isFound, true);
        },
      );
    });

    test('should not match when positions differ', () {
      // Arrange
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [testWord],
        selectedPositions: [
          const Position(1, 0),
          const Position(1, 1),
          const Position(1, 2),
          const Position(1, 3),
        ],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act
      final result = useCase(currentState: state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.foundWordsCount, 0);
          expect(newState.words.first.isFound, false);
          expect(newState.selectedPositions.isEmpty, true);
        },
      );
    });

    test('should set status to completed when all words found', () {
      // Arrange
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [testWord], // Only one word
        selectedPositions: [
          const Position(0, 0),
          const Position(0, 1),
          const Position(0, 2),
          const Position(0, 3),
        ],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act
      final result = useCase(currentState: state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.foundWordsCount, 1);
          expect(newState.status, GameStatus.completed);
        },
      );
    });

    test('should clear selection when less than 2 positions', () {
      // Arrange
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [testWord],
        selectedPositions: [const Position(0, 0)],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 0,
      );

      // Act
      final result = useCase(currentState: state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.selectedPositions.isEmpty, true);
          expect(newState.foundWordsCount, 0);
        },
      );
    });

    test('should not match already found words', () {
      // Arrange
      final foundWord = testWord.copyWith(isFound: true);
      final state = GameState(
        grid: List.generate(8, (_) => List.filled(8, 'A')),
        words: [foundWord],
        selectedPositions: [
          const Position(0, 0),
          const Position(0, 1),
          const Position(0, 2),
          const Position(0, 3),
        ],
        difficulty: GameDifficulty.easy,
        status: GameStatus.playing,
        foundWordsCount: 1,
      );

      // Act
      final result = useCase(currentState: state);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.foundWordsCount, 1); // No change
          expect(newState.selectedPositions.isEmpty, true);
        },
      );
    });
  });
}
