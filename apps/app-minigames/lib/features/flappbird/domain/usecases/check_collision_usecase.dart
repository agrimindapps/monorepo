// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';
import '../services/collision_service.dart';

/// Use case to check collision between bird and pipes
class CheckCollisionUseCase {
  final CollisionService _collisionService;

  CheckCollisionUseCase(this._collisionService);

  Future<Either<Failure, FlappyGameState>> call({
    required FlappyGameState currentState,
  }) async {
    try {
      // Only check collision when playing
      if (!currentState.isPlaying) {
        return Right(currentState);
      }

      // Check collision with pipes using service
      if (_collisionService.checkBirdPipesCollision(
        bird: currentState.bird,
        pipes: currentState.pipes,
        birdX: currentState.birdX,
      )) {
        // Collision detected - game over
        return Right(
          currentState.copyWith(status: FlappyGameStatus.gameOver),
        );
      }

      // No collision
      return Right(currentState);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check collision: $e'));
    }
  }
}
