import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../entities/game_state_entity.dart';
import '../services/ball_physics_service.dart';

@lazySingleton
class UpdateBallUseCase {
  final BallPhysicsService _physicsService;

  UpdateBallUseCase(this._physicsService);

  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    if (!state.canPlay) {
      return Left(ValidationFailure('Game is not active'));
    }

    try {
      var ball = _physicsService.moveBall(state.ball);

      if (ball.y <= 0.0 || ball.y >= 1.0) {
        ball = _physicsService.bounceVertical(ball);
      }

      return Right(state.copyWith(ball: ball));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update ball: $e'));
    }
  }
}
