import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/game_state_entity.dart';

class CheckCollisionUseCase {
  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    if (!state.canPlay) {
      return Left(ValidationFailure('Game is not active'));
    }

    try {
      var ball = state.ball;
      var currentRally = state.currentRally;
      var totalHits = state.totalHits;

      if (state.playerPaddle.collidesWith(ball)) {
        final hitPos = state.playerPaddle.getHitPosition(ball);
        ball = ball.bounceHorizontal().setAngle(hitPos).capSpeed();
        currentRally++;
        totalHits++;
      } else if (state.aiPaddle.collidesWith(ball)) {
        final hitPos = state.aiPaddle.getHitPosition(ball);
        ball = ball.bounceHorizontal().setAngle(hitPos).capSpeed();
        currentRally++;
        totalHits++;
      }

      return Right(state.copyWith(
        ball: ball,
        currentRally: currentRally,
        totalHits: totalHits,
      ));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check collision: $e'));
    }
  }
}
