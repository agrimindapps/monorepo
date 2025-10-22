import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/card_entity.dart';
import '../entities/enums.dart';
import '../entities/game_state_entity.dart';

class CheckMatchUseCase {
  Either<Failure, GameStateEntity> call(GameStateEntity currentState) {
    try {
      if (currentState.flippedCards.length != 2) {
        return const Left(
          ValidationFailure('Must have exactly 2 flipped cards to check match'),
        );
      }

      final card1 = currentState.flippedCards[0];
      final card2 = currentState.flippedCards[1];

      final updatedCards = List<CardEntity>.from(currentState.cards);
      bool isMatch = card1.matches(card2);

      if (isMatch) {
        for (int i = 0; i < updatedCards.length; i++) {
          if (updatedCards[i].id == card1.id ||
              updatedCards[i].id == card2.id) {
            updatedCards[i] = updatedCards[i].copyWith(
              state: CardState.matched,
            );
          }
        }

        final newMatches = currentState.matches + 1;
        final newStatus = newMatches == currentState.totalPairs
            ? GameStatus.completed
            : currentState.status;

        return Right(
          currentState.copyWith(
            cards: updatedCards,
            flippedCards: [],
            matches: newMatches,
            moves: currentState.moves + 1,
            status: newStatus,
          ),
        );
      } else {
        for (int i = 0; i < updatedCards.length; i++) {
          if (updatedCards[i].id == card1.id ||
              updatedCards[i].id == card2.id) {
            updatedCards[i] = updatedCards[i].copyWith(
              state: CardState.hidden,
            );
          }
        }

        return Right(
          currentState.copyWith(
            cards: updatedCards,
            flippedCards: [],
            moves: currentState.moves + 1,
          ),
        );
      }
    } catch (e) {
      return Left(CacheFailure('Failed to check match: $e'));
    }
  }
}
