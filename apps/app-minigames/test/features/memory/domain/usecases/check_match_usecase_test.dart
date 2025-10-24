import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/memory/domain/entities/card_entity.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/memory/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/memory/domain/usecases/check_match_usecase.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late CheckMatchUseCase useCase;

  setUp(() {
    useCase = CheckMatchUseCase();
  });

  group('CheckMatchUseCase', () {
    test('should return success with matched cards when cards match', () {
      // Arrange
      final gameState = TestFixtures.createGameStateWithTwoFlippedCards(
        matching: true,
      );

      // Act
      final result = useCase(gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.matches, gameState.matches + 1);
          expect(newState.flippedCards.isEmpty, true);
          expect(newState.moves, gameState.moves + 1);

          // Check that matched cards have state = matched
          final matchedCards = newState.cards
              .where((card) => card.state == CardState.matched)
              .toList();
          expect(matchedCards.length, 2);
        },
      );
    });

    test('should return success with unmatched cards when cards dont match', () {
      // Arrange
      final gameState = TestFixtures.createGameStateWithTwoFlippedCards(
        matching: false,
      );

      // Act
      final result = useCase(gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.matches, gameState.matches);
          expect(newState.flippedCards.isEmpty, true);
          expect(newState.moves, gameState.moves + 1);

          // Check that non-matched cards are hidden again
          final flippedCardIds = gameState.flippedCards.map((c) => c.id).toList();
          final resetCards = newState.cards
              .where((card) => flippedCardIds.contains(card.id))
              .toList();

          for (final card in resetCards) {
            expect(card.state, CardState.hidden);
          }
        },
      );
    });

    test('should mark game as completed when all cards are matched', () {
      // Arrange - Create game state where only 1 pair remains
      // Easy difficulty has 8 pairs (4x4 grid = 16 cards)
      // We'll have 7 pairs matched, and match the 8th pair
      final cards = List.generate(16, (i) {
        final pairId = i ~/ 2;
        if (i < 14) {
          // First 7 pairs already matched
          return TestFixtures.createCard(
            id: 'card_$i',
            pairId: pairId,
            state: CardState.matched,
            position: i,
          );
        } else {
          // Last pair (pairId 7) currently revealed
          return TestFixtures.createCard(
            id: 'card_$i',
            pairId: pairId,
            state: CardState.revealed,
            position: i,
          );
        }
      });

      final gameState = GameStateEntity(
        cards: cards,
        flippedCards: [cards[14], cards[15]], // Last pair
        moves: 7,
        matches: 7, // Already matched 7 pairs
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      // Act
      final result = useCase(gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.status, GameStatus.completed);
          expect(newState.matches, 8); // All 8 pairs matched
          expect(newState.isGameWon, true);
        },
      );
    });

    test('should return failure when no cards are flipped', () {
      // Arrange
      final gameState = TestFixtures.createGameState(
        status: GameStatus.playing,
        flippedCards: [],
      );

      // Act
      final result = useCase(gameState);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Must have exactly 2 flipped cards to check match');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when only one card is flipped', () {
      // Arrange
      final gameState = TestFixtures.createGameStateWithOneFlippedCard();

      // Act
      final result = useCase(gameState);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Must have exactly 2 flipped cards to check match');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when more than two cards are flipped', () {
      // Arrange
      final cards = [
        TestFixtures.createCard(id: 'card_0', pairId: 0, state: CardState.revealed),
        TestFixtures.createCard(id: 'card_1', pairId: 0, state: CardState.revealed),
        TestFixtures.createCard(id: 'card_2', pairId: 1, state: CardState.revealed),
        TestFixtures.createCard(id: 'card_3', pairId: 1, state: CardState.hidden),
      ];

      final gameState = GameStateEntity(
        cards: cards,
        flippedCards: [cards[0], cards[1], cards[2]], // 3 cards!
        moves: 0,
        matches: 0,
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      // Act
      final result = useCase(gameState);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Must have exactly 2 flipped cards to check match');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should increment moves counter on every check', () {
      // Arrange
      final gameStateMatch = TestFixtures.createGameStateWithTwoFlippedCards(
        matching: true,
      );
      final gameStateNoMatch = TestFixtures.createGameStateWithTwoFlippedCards(
        matching: false,
      );

      // Act
      final resultMatch = useCase(gameStateMatch);
      final resultNoMatch = useCase(gameStateNoMatch);

      // Assert
      resultMatch.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.moves, gameStateMatch.moves + 1);
        },
      );

      resultNoMatch.fold(
        (_) => fail('Should not return failure'),
        (newState) {
          expect(newState.moves, gameStateNoMatch.moves + 1);
        },
      );
    });
  });
}
