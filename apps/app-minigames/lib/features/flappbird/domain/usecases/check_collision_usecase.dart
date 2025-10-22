// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';

/// Use case to check collision between bird and pipes
class CheckCollisionUseCase {
  Future<Either<Failure, FlappyGameState>> call({
    required FlappyGameState currentState,
  }) async {
    try {
      // Only check collision when playing
      if (!currentState.isPlaying) {
        return Right(currentState);
      }

      final birdX = currentState.birdX;
      final birdY = currentState.bird.y;
      final birdSize = currentState.bird.size;

      // Check collision with each pipe
      for (final pipe in currentState.pipes) {
        if (pipe.checkCollision(birdX, birdY, birdSize)) {
          // Collision detected - game over
          return Right(
            currentState.copyWith(status: FlappyGameStatus.gameOver),
          );
        }
      }

      // No collision
      return Right(currentState);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check collision: $e'));
    }
  }
}
