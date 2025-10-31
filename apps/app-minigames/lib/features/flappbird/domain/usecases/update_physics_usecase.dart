// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';
import '../services/physics_service.dart';
import '../services/collision_service.dart';

/// Use case to update bird physics (gravity, position, boundaries)
/// Supports delta time for frame-rate independent movement
class UpdatePhysicsUseCase {
  final PhysicsService _physicsService;
  final CollisionService _collisionService;

  UpdatePhysicsUseCase(
    this._physicsService,
    this._collisionService,
  );

  Future<Either<Failure, FlappyGameState>> call({
    required FlappyGameState currentState,
    double deltaTimeSeconds = 1.0 / 60.0,
  }) async {
    try {
      // Only update physics when playing
      if (!currentState.isPlaying) {
        return Right(currentState);
      }

      // Apply gravity to bird with delta time
      final newBird = _physicsService.applyGravity(
        bird: currentState.bird,
        deltaTimeSeconds: deltaTimeSeconds,
      );

      // Check if bird is out of bounds
      final boundaryCollision = _collisionService.checkAllCollisions(
        bird: newBird,
        pipes: currentState.pipes,
        birdX: currentState.birdX,
        playAreaHeight: currentState.playAreaHeight,
      );

      if (boundaryCollision.hasCollision &&
          (boundaryCollision.type == CollisionType.ground ||
              boundaryCollision.type == CollisionType.ceiling)) {
        return Right(
          currentState.copyWith(
            bird: newBird,
            status: FlappyGameStatus.gameOver,
          ),
        );
      }

      return Right(currentState.copyWith(bird: newBird));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update physics: $e'));
    }
  }
}
