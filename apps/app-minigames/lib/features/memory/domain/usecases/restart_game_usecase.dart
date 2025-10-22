import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';
import 'generate_cards_usecase.dart';

class RestartGameParams {
  final GameDifficulty difficulty;

  const RestartGameParams({required this.difficulty});
}

class RestartGameUseCase {
  final GenerateCardsUseCase _generateCardsUseCase;

  RestartGameUseCase(this._generateCardsUseCase);

  Either<Failure, GameStateEntity> call(RestartGameParams params) {
    try {
      final cardsResult = _generateCardsUseCase(
        GenerateCardsParams(difficulty: params.difficulty),
      );

      return cardsResult.fold(
        (failure) => Left(failure),
        (cards) => Right(
          GameStateEntity(
            cards: cards,
            difficulty: params.difficulty,
            status: GameStatus.initial,
            startTime: null,
            elapsedTime: null,
          ),
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to restart game: $e'));
    }
  }
}
