import 'package:core/core.dart';
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';

class UpdatePlayerPaddleUseCase {
  static const double paddleSpeed = 0.008;

  Future<Either<Failure, GameStateEntity>> call(
    GameStateEntity state,
    PaddleDirection direction,
  ) async {
    if (!state.canPlay) {
      return const Left(ValidationFailure('Game is not active'));
    }

    try {
      var playerPaddle = state.playerPaddle;

      switch (direction) {
        case PaddleDirection.up:
          playerPaddle = playerPaddle.moveUp(paddleSpeed);
          break;
        case PaddleDirection.down:
          playerPaddle = playerPaddle.moveDown(paddleSpeed);
          break;
        case PaddleDirection.stop:
          break;
      }

      return Right(state.copyWith(playerPaddle: playerPaddle));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update player paddle: $e'));
    }
  }
}
