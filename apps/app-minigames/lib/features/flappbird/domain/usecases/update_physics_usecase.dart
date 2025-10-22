// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/game_state_entity.dart';
import '../entities/enums.dart';

/// Use case to update bird physics (gravity, position, boundaries)
class UpdatePhysicsUseCase {
  /// Gravity constant (pixels per frame)
  static const double gravity = 0.6;

  Future<Either<Failure, FlappyGameState>> call({
    required FlappyGameState currentState,
  }) async {
    try {
      // Only update physics when playing
      if (!currentState.isPlaying) {
        return Right(currentState);
      }

      // Apply gravity to bird
      final newBird = currentState.bird.applyGravity(gravity);

      // Check if bird hit ground or ceiling
      if (newBird.isOutOfBounds(currentState.playAreaHeight)) {
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
