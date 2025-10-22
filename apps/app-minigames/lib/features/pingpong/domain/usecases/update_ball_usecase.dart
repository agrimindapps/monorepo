import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/game_state_entity.dart';

class UpdateBallUseCase {
  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    if (!state.canPlay) {
      return Left(ValidationFailure('Game is not active'));
    }

    try {
      var ball = state.ball.move();

      if (ball.y <= 0.0 || ball.y >= 1.0) {
        ball = ball.bounceVertical();
      }

      return Right(state.copyWith(ball: ball));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update ball: $e'));
    }
  }
}
