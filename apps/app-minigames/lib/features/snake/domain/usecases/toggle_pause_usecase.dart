// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/enums.dart';

/// Use case to toggle pause
class TogglePauseUseCase {
  TogglePauseUseCase();

  /// Execute the use case
  /// Toggles between running and paused
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeGameState currentState,
  }) async {
    if (currentState.gameStatus.isRunning) {
      return Right(currentState.copyWith(gameStatus: SnakeGameStatus.paused));
    } else if (currentState.gameStatus.isPaused) {
      return Right(currentState.copyWith(gameStatus: SnakeGameStatus.running));
    }

    return const Left(GameLogicFailure('Cannot toggle pause in current state'));
  }
}
