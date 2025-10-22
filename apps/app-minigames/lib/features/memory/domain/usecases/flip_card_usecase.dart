import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/card_entity.dart';
import '../entities/enums.dart';
import '../entities/game_state_entity.dart';

class FlipCardParams {
  final GameStateEntity currentState;
  final String cardId;

  const FlipCardParams({
    required this.currentState,
    required this.cardId,
  });
}

class FlipCardUseCase {
  Either<Failure, GameStateEntity> call(FlipCardParams params) {
    try {
      final state = params.currentState;
      final cardId = params.cardId;

      if (cardId.trim().isEmpty) {
        return const Left(ValidationFailure('Card ID cannot be empty'));
      }

      if (!state.canFlipCard) {
        return const Left(
          ValidationFailure('Cannot flip card in current state'),
        );
      }

      final cardIndex = state.cards.indexWhere((c) => c.id == cardId);
      if (cardIndex == -1) {
        return const Left(ValidationFailure('Card not found'));
      }

      final card = state.cards[cardIndex];

      if (card.isFlipped) {
        return const Left(ValidationFailure('Card is already flipped'));
      }

      if (card.isMatched) {
        return const Left(ValidationFailure('Card is already matched'));
      }

      if (state.flippedCards.any((c) => c.id == cardId)) {
        return const Left(ValidationFailure('Card is already in flipped list'));
      }

      final updatedCards = List<CardEntity>.from(state.cards);
      updatedCards[cardIndex] = card.copyWith(state: CardState.revealed);

      final updatedFlippedCards = List<CardEntity>.from(state.flippedCards)
        ..add(updatedCards[cardIndex]);

      final newState = state.copyWith(
        cards: updatedCards,
        flippedCards: updatedFlippedCards,
      );

      return Right(newState);
    } catch (e) {
      return Left(CacheFailure('Failed to flip card: $e'));
    }
  }
}
