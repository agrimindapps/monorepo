import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/memory/domain/entities/card_entity.dart';
import 'package:app_minigames/features/memory/domain/entities/enums.dart';
import 'package:app_minigames/features/memory/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/memory/domain/usecases/check_match_usecase.dart';
import 'package:flutter/material.dart';

void main() {
  late CheckMatchUseCase useCase;

  setUp(() {
    useCase = CheckMatchUseCase();
  });

  group('CheckMatchUseCase', () {
    final matchingCard1 = const CardEntity(
      id: 'card_0',
      pairId: 0,
      color: Colors.red,
      icon: Icons.star,
      state: CardState.revealed,
      position: 0,
    );

    final matchingCard2 = const CardEntity(
      id: 'card_1',
      pairId: 0,
      color: Colors.red,
      icon: Icons.star,
      state: CardState.revealed,
      position: 1,
    );

    final nonMatchingCard = const CardEntity(
      id: 'card_2',
      pairId: 1,
      color: Colors.blue,
      icon: Icons.home,
      state: CardState.revealed,
      position: 2,
    );

    test('should mark cards as matched when they match', () {
      final testState = GameStateEntity(
        cards: [matchingCard1, matchingCard2],
        flippedCards: [matchingCard1, matchingCard2],
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final result = useCase(testState);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.matches, 1);
          expect(newState.moves, 1);
          expect(newState.flippedCards.length, 0);
          expect(
            newState.cards.where((c) => c.state == CardState.matched).length,
            2,
          );
        },
      );
    });

    test('should flip cards back when they do not match', () {
      final testState = GameStateEntity(
        cards: [matchingCard1, nonMatchingCard],
        flippedCards: [matchingCard1, nonMatchingCard],
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final result = useCase(testState);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.matches, 0);
          expect(newState.moves, 1);
          expect(newState.flippedCards.length, 0);
          expect(
            newState.cards.where((c) => c.state == CardState.hidden).length,
            2,
          );
        },
      );
    });

    test('should increment moves counter on match', () {
      final testState = GameStateEntity(
        cards: [matchingCard1, matchingCard2],
        flippedCards: [matchingCard1, matchingCard2],
        moves: 5,
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final result = useCase(testState);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.moves, 6);
        },
      );
    });

    test('should increment moves counter on no match', () {
      final testState = GameStateEntity(
        cards: [matchingCard1, nonMatchingCard],
        flippedCards: [matchingCard1, nonMatchingCard],
        moves: 3,
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final result = useCase(testState);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.moves, 4);
        },
      );
    });

    test('should clear flippedCards on match', () {
      final testState = GameStateEntity(
        cards: [matchingCard1, matchingCard2],
        flippedCards: [matchingCard1, matchingCard2],
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final result = useCase(testState);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.flippedCards, isEmpty);
        },
      );
    });

    test('should clear flippedCards on no match', () {
      final testState = GameStateEntity(
        cards: [matchingCard1, nonMatchingCard],
        flippedCards: [matchingCard1, nonMatchingCard],
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final result = useCase(testState);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.flippedCards, isEmpty);
        },
      );
    });

    test('should return failure when not exactly 2 cards flipped', () {
      final testState = GameStateEntity(
        cards: [matchingCard1, matchingCard2],
        flippedCards: [matchingCard1],
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final result = useCase(testState);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(
            failure.message,
            'Must have exactly 2 flipped cards to check match',
          );
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should set status to completed when all pairs matched', () {
      final allCards = [matchingCard1, matchingCard2];
      final testState = GameStateEntity(
        cards: allCards,
        flippedCards: [matchingCard1, matchingCard2],
        matches: 0,
        status: GameStatus.playing,
        difficulty: GameDifficulty.easy,
      );

      final result = useCase(testState);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.status, GameStatus.completed);
          expect(newState.matches, 1);
        },
      );
    });
  });
}
