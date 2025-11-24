import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';

/// Use case for toggling pause state
class TogglePauseUseCase {
  TogglePauseUseCase();

  Either<Failure, GameState> call(GameState currentState) {
    // Cannot pause if game is over
    if (currentState.isGameOver) {
      return const Left(GameLogicFailure('Cannot pause when game is over'));
    }

    return Right(currentState.copyWith(
      isPaused: !currentState.isPaused,
    ));
  }
}
