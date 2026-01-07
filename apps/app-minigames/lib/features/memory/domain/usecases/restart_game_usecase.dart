import 'package:dartz/dartz.dart';
import 'package:app_minigames/core/error/failures.dart';
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';
import '../services/card_generator_service.dart'; // Changed from UseCase to Service direct usage or update UseCase
import '../entities/deck_configuration.dart';

class RestartGameParams {
  final GameDifficulty difficulty;
  final DeckConfiguration? deckConfig;

  const RestartGameParams({
    required this.difficulty,
    this.deckConfig,
  });
}

class RestartGameUseCase {
  final CardGeneratorService _cardGeneratorService;

  RestartGameUseCase(this._cardGeneratorService);

  Either<Failure, GameStateEntity> call(RestartGameParams params) {
    try {
      final cards = _cardGeneratorService.generateCards(
        params.difficulty,
        deckConfig: params.deckConfig,
      );

      return Right(
        GameStateEntity(
          cards: cards,
          difficulty: params.difficulty,
          status: GameStatus.initial,
          startTime: null,
          elapsedTime: null,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to restart game: $e'));
    }
  }
}
