import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../entities/game_state_entity.dart';
import '../services/collision_detection_service.dart';
import '../services/ball_physics_service.dart';

@lazySingleton
class CheckCollisionUseCase {
  final CollisionDetectionService _collisionService;
  final BallPhysicsService _physicsService;

  CheckCollisionUseCase(this._collisionService, this._physicsService);

  Future<Either<Failure, GameStateEntity>> call(GameStateEntity state) async {
    if (!state.canPlay) {
      return Left(ValidationFailure('Game is not active'));
    }

    try {
      var ball = state.ball;
      var currentRally = state.currentRally;
      var totalHits = state.totalHits;

      final collisionResult = _collisionService.checkPaddleCollisions(
        playerPaddle: state.playerPaddle,
        aiPaddle: state.aiPaddle,
        ball: ball,
      );

      if (collisionResult.hasCollision) {
        final hitPos = collisionResult.hitPosition ?? 0.0;

        ball = _physicsService.bounceHorizontal(ball);
        ball = _physicsService.setAngle(ball, hitPos);
        ball = _physicsService.capSpeed(ball);

        currentRally++;
        totalHits++;
      }

      return Right(
        state.copyWith(
          ball: ball,
          currentRally: currentRally,
          totalHits: totalHits,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check collision: $e'));
    }
  }
}
