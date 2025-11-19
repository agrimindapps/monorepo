import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../entities/game_state_entity.dart';
import '../entities/ball_entity.dart';
import '../entities/paddle_entity.dart';
import '../entities/enums.dart';

@lazySingleton
class StartGameUseCase {
  Future<Either<Failure, GameStateEntity>> call(
    GameStateEntity currentState,
    GameDifficulty difficulty,
  ) async {
    try {
      return Right(
        GameStateEntity(
          ball: BallEntity.initial(),
          playerPaddle: PaddleEntity.player(),
          aiPaddle: PaddleEntity.ai(),
          playerScore: 0,
          aiScore: 0,
          status: GameStatus.playing,
          difficulty: difficulty,
          startTime: DateTime.now(),
          totalHits: 0,
          currentRally: 0,
          maxRally: 0,
          highScore: currentState.highScore,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to start game: $e'));
    }
  }
}
