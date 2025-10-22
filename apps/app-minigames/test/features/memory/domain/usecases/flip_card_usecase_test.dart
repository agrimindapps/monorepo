import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/memory/domain/entities/card_entity.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/memory/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/memory/domain/usecases/flip_card_usecase.dart';
import 'package:flutter/material.dart';

void main() {
  late FlipCardUseCase useCase;

  setUp(() {
    useCase = FlipCardUseCase();
  });

  group('FlipCardUseCase', () {
    final testCards = [
      const CardEntity(
        id: 'card_0',
        pairId: 0,
        color: Colors.red,
        icon: Icons.star,
        position: 0,
      ),
      const CardEntity(
        id: 'card_1',
        pairId: 0,
        color: Colors.red,
        icon: Icons.star,
        position: 1,
      ),
      const CardEntity(
        id: 'card_2',
        pairId: 1,
        color: Colors.blue,
        icon: Icons.home,
        position: 2,
      ),
    ];

    final testState = GameStateEntity(
      cards: testCards,
      status: GameStatus.playing,
      difficulty: GameDifficulty.easy,
    );

    test('should flip card when valid', () {
      final params = FlipCardParams(
        currentState: testState,
        cardId: 'card_0',
      );

      final result = useCase(params);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.flippedCards.length, 1);
          expect(newState.flippedCards.first.id, 'card_0');
          expect(newState.flippedCards.first.state, CardState.revealed);
        },
      );
    });

    test('should not flip already flipped card', () {
      final flippedCard = testCards[0].copyWith(state: CardState.revealed);
      final stateWithFlipped = testState.copyWith(
        cards: [flippedCard, testCards[1], testCards[2]],
      );

      final params = FlipCardParams(
        currentState: stateWithFlipped,
        cardId: 'card_0',
      );

      final result = useCase(params);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card is already flipped');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should not flip matched card', () {
      final matchedCard = testCards[0].copyWith(state: CardState.matched);
      final stateWithMatched = testState.copyWith(
        cards: [matchedCard, testCards[1], testCards[2]],
      );

      final params = FlipCardParams(
        currentState: stateWithMatched,
        cardId: 'card_0',
      );

      final result = useCase(params);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card is already matched');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should not flip when 2 cards already flipped', () {
      final flippedCard1 = testCards[0].copyWith(state: CardState.revealed);
      final flippedCard2 = testCards[1].copyWith(state: CardState.revealed);

      final stateWithTwoFlipped = testState.copyWith(
        cards: [flippedCard1, flippedCard2, testCards[2]],
        flippedCards: [flippedCard1, flippedCard2],
      );

      final params = FlipCardParams(
        currentState: stateWithTwoFlipped,
        cardId: 'card_2',
      );

      final result = useCase(params);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Cannot flip card in current state');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when card ID is empty', () {
      final params = FlipCardParams(
        currentState: testState,
        cardId: '',
      );

      final result = useCase(params);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card ID cannot be empty');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when card not found', () {
      final params = FlipCardParams(
        currentState: testState,
        cardId: 'non_existent_card',
      );

      final result = useCase(params);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Card not found');
        },
        (_) => fail('Should not return success'),
      );
    });
  });
}
