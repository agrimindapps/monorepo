import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/memory/domain/usecases/flip_card_usecase.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late FlipCardUseCase useCase;

  setUp(() {
    useCase = FlipCardUseCase();
  });

  group('FlipCardUseCase', () {
    test('should flip card successfully when card is hidden and game is playing', () {
      // Arrange
      final gameState = TestFixtures.createGameState(
        status: GameStatus.playing,
      );
      final cardToFlip = gameState.cards.first;

      final params = FlipCardParams(
        currentState: gameState,
        cardId: cardToFlip.id,
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.flippedCards.length, 1);
          expect(newState.flippedCards.first.id, cardToFlip.id);
          expect(newState.flippedCards.first.state, CardState.revealed);

          // Check that the card in the cards list is also updated
          final updatedCard = newState.cards.firstWhere((c) => c.id == cardToFlip.id);
          expect(updatedCard.state, CardState.revealed);
        },
      );
    });

    test('should flip second card successfully when one card is already flipped', () {
      // Arrange
      final gameState = TestFixtures.createGameStateWithOneFlippedCard();
      final cardToFlip = gameState.cards[1]; // Flip second card

      final params = FlipCardParams(
        currentState: gameState,
        cardId: cardToFlip.id,
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.flippedCards.length, 2);
          expect(newState.flippedCards.map((c) => c.id), contains(cardToFlip.id));
        },
      );
    });

    test('should return failure when card ID is empty', () {
      // Arrange
      final gameState = TestFixtures.createGameState(status: GameStatus.playing);
      final params = FlipCardParams(
        currentState: gameState,
        cardId: '',
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card ID cannot be empty');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when card ID contains only whitespace', () {
      // Arrange
      final gameState = TestFixtures.createGameState(status: GameStatus.playing);
      final params = FlipCardParams(
        currentState: gameState,
        cardId: '   ',
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card ID cannot be empty');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when card is not found', () {
      // Arrange
      final gameState = TestFixtures.createGameState(status: GameStatus.playing);
      final params = FlipCardParams(
        currentState: gameState,
        cardId: 'non_existent_card_id',
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card not found');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when card is already flipped', () {
      // Arrange
      final gameState = TestFixtures.createGameStateWithOneFlippedCard();
      final alreadyFlippedCard = gameState.flippedCards.first;

      final params = FlipCardParams(
        currentState: gameState,
        cardId: alreadyFlippedCard.id,
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card is already flipped');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when card is already matched', () {
      // Arrange
      final cards = [
        TestFixtures.createCard(id: 'card_0', pairId: 0, state: CardState.matched),
        TestFixtures.createCard(id: 'card_1', pairId: 0, state: CardState.matched),
        TestFixtures.createCard(id: 'card_2', pairId: 1, state: CardState.hidden),
        TestFixtures.createCard(id: 'card_3', pairId: 1, state: CardState.hidden),
      ];

      final gameState = TestFixtures.createGameState(
        cards: cards,
        status: GameStatus.playing,
      );

      final params = FlipCardParams(
        currentState: gameState,
        cardId: 'card_0', // Matched card
      );

      // Act
      final result = useCase(params);

      // Assert
      // Note: Matched cards also have isFlipped=true, so this check happens first
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card is already flipped');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when two cards are already flipped', () {
      // Arrange
      final gameState = TestFixtures.createGameStateWithTwoFlippedCards();
      final hiddenCard = gameState.cards.firstWhere(
        (c) => c.state == CardState.hidden,
      );

      final params = FlipCardParams(
        currentState: gameState,
        cardId: hiddenCard.id,
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Cannot flip card in current state');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when game is not in playing status', () {
      // Arrange
      final gameState = TestFixtures.createGameState(
        status: GameStatus.paused,
      );
      final cardToFlip = gameState.cards.first;

      final params = FlipCardParams(
        currentState: gameState,
        cardId: cardToFlip.id,
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Cannot flip card in current state');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when game is completed', () {
      // Arrange
      final gameState = TestFixtures.createGameState(
        status: GameStatus.completed,
      );
      final cardToFlip = gameState.cards.first;

      final params = FlipCardParams(
        currentState: gameState,
        cardId: cardToFlip.id,
      );

      // Act
      final result = useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Cannot flip card in current state');
        },
        (_) => fail('Should not return success'),
      );
    });
  });
}
