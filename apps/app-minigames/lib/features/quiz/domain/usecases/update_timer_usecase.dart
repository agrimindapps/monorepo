// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';

/// Use case to update timer (decrement 1 second)
class UpdateTimerUseCase {
  UpdateTimerUseCase();

  /// Execute the use case
  /// Decrements timer by 1 second
  Future<Either<Failure, QuizGameState>> call({
    required QuizGameState currentState,
  }) async {
    // Validation: game must be playing
    if (!currentState.gameStatus.isPlaying) {
      return Left(GameLogicFailure('Game is not in progress'));
    }

    // Decrement timer
    final newTimeLeft = currentState.timeLeft - 1;

    return Right(currentState.copyWith(
      timeLeft: newTimeLeft,
    ));
  }
}
