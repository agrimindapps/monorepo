import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/memory/domain/usecases/restart_game_usecase.dart';
import 'package:app_minigames/features/memory/domain/usecases/generate_cards_usecase.dart';
import '../../../../helpers/test_fixtures.dart';
import '../../../../helpers/mock_repositories.dart';

void main() {
  late RestartGameUseCase useCase;
  late MockGenerateCardsUseCase mockGenerateCardsUseCase;

  setUp(() {
    mockGenerateCardsUseCase = MockGenerateCardsUseCase();
    useCase = RestartGameUseCase(mockGenerateCardsUseCase);

    // Register fallback values
    registerFallbackValue(const GenerateCardsParams(difficulty: GameDifficulty.easy));
  });

  group('RestartGameUseCase', () {
    test('should restart game successfully with easy difficulty', () {
      // Arrange
      final cards = TestFixtures.createCardPair(pairId: 0) +
          TestFixtures.createCardPair(pairId: 1);

      when(() => mockGenerateCardsUseCase(any()))
          .thenReturn(Right(cards));

      const params = RestartGameParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (gameState) {
          expect(gameState.cards.length, cards.length);
          expect(gameState.difficulty, GameDifficulty.easy);
          expect(gameState.status, GameStatus.initial);
          expect(gameState.moves, 0);
          expect(gameState.matches, 0);
          expect(gameState.flippedCards.isEmpty, true);
          expect(gameState.startTime, null);
          expect(gameState.elapsedTime, null);
        },
      );

      verify(() => mockGenerateCardsUseCase(any())).called(1);
    });

    test('should restart game successfully with medium difficulty', () {
      // Arrange
      final cards = List.generate(
        9,
        (i) => TestFixtures.createCardPair(pairId: i),
      ).expand((pair) => pair).toList();

      when(() => mockGenerateCardsUseCase(any()))
          .thenReturn(Right(cards));

      const params = RestartGameParams(difficulty: GameDifficulty.medium);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (gameState) {
          expect(gameState.difficulty, GameDifficulty.medium);
          expect(gameState.status, GameStatus.initial);
        },
      );

      verify(() => mockGenerateCardsUseCase(any())).called(1);
    });

    test('should restart game successfully with hard difficulty', () {
      // Arrange
      final cards = List.generate(
        16,
        (i) => TestFixtures.createCardPair(pairId: i),
      ).expand((pair) => pair).toList();

      when(() => mockGenerateCardsUseCase(any()))
          .thenReturn(Right(cards));

      const params = RestartGameParams(difficulty: GameDifficulty.hard);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (gameState) {
          expect(gameState.difficulty, GameDifficulty.hard);
          expect(gameState.status, GameStatus.initial);
        },
      );

      verify(() => mockGenerateCardsUseCase(any())).called(1);
    });

    test('should propagate failure when card generation fails', () {
      // Arrange
      const failure = CacheFailure('Failed to generate cards');

      when(() => mockGenerateCardsUseCase(any()))
          .thenReturn(const Left(failure));

      const params = RestartGameParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<CacheFailure>());
          expect(f.message, 'Failed to generate cards');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should reset all game state counters to zero', () {
      // Arrange
      final cards = TestFixtures.createCardPair(pairId: 0) +
          TestFixtures.createCardPair(pairId: 1);

      when(() => mockGenerateCardsUseCase(any()))
          .thenReturn(Right(cards));

      const params = RestartGameParams(difficulty: GameDifficulty.easy);

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (gameState) {
          expect(gameState.moves, 0);
          expect(gameState.matches, 0);
          expect(gameState.flippedCards.length, 0);
          expect(gameState.startTime, null);
          expect(gameState.elapsedTime, null);
          expect(gameState.errorMessage, null);
        },
      );
    });

    test('should call generate cards with correct difficulty', () {
      // Arrange
      final cards = TestFixtures.createCardPair(pairId: 0);

      when(() => mockGenerateCardsUseCase(any()))
          .thenReturn(Right(cards));

      const params = RestartGameParams(difficulty: GameDifficulty.hard);

      // Act
      useCase(params);

      // Assert
      verify(() => mockGenerateCardsUseCase(any())).called(1);
    });

    test('should return fresh game state on each restart', () {
      // Arrange
      final cards1 = TestFixtures.createCardPair(pairId: 0);
      final cards2 = TestFixtures.createCardPair(pairId: 1);

      when(() => mockGenerateCardsUseCase(any()))
          .thenReturn(Right(cards1));

      const params = RestartGameParams(difficulty: GameDifficulty.easy);

      // Act - First restart
      final result1 = useCase(params);

      // Change mock return
      when(() => mockGenerateCardsUseCase(any()))
          .thenReturn(Right(cards2));

      // Act - Second restart
      final result2 = useCase(params);

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      final state1 = result1.getOrElse(() => TestFixtures.createGameState());
      final state2 = result2.getOrElse(() => TestFixtures.createGameState());

      // Both should be fresh states
      expect(state1.moves, 0);
      expect(state2.moves, 0);
      expect(state1.status, GameStatus.initial);
      expect(state2.status, GameStatus.initial);

      verify(() => mockGenerateCardsUseCase(any())).called(2);
    });
  });
}
