// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case to change snake direction
class ChangeDirectionUseCase {
  ChangeDirectionUseCase();

  /// Execute the use case
  /// Validates that new direction is not opposite to current
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeGameState currentState,
    required Direction newDirection,
  }) async {
    // Validation: cannot go in opposite direction
    if (currentState.direction.isOpposite(newDirection)) {
      return Left(ValidationFailure('Cannot go in opposite direction'));
    }

    return Right(currentState.copyWith(direction: newDirection));
  }
}
