// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/game_state_entity.dart';

/// Use case to make the bird flap (jump)
class FlapBirdUseCase {
  /// Jump strength constant (negative = upward)
  static const double jumpStrength = -10.0;

  Future<Either<Failure, FlappyGameState>> call({
    required FlappyGameState currentState,
  }) async {
    try {
      // Can only flap when game is playing
      if (!currentState.isPlaying) {
        return Left(
          ValidationFailure('Cannot flap when game is not playing'),
        );
      }

      // Apply flap to bird
      final newBird = currentState.bird.flap(jumpStrength);

      return Right(currentState.copyWith(bird: newBird));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to flap bird: $e'));
    }
  }
}
