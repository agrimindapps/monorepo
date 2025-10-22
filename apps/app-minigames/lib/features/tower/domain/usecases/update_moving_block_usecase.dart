import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';

/// Use case for updating the position of the moving block
/// Handles horizontal movement and direction changes at boundaries
@injectable
class UpdateMovingBlockUseCase {
  UpdateMovingBlockUseCase();

  Either<Failure, GameState> call(GameState currentState) {
    // Don't update if paused or game over
    if (currentState.isPaused || currentState.isGameOver) {
      return Right(currentState);
    }

    var newPosX = currentState.currentBlockPosX;
    var newMovingRight = currentState.movingRight;

    // Update position based on direction
    if (currentState.movingRight) {
      newPosX += currentState.blockSpeed;
      // Check right boundary
      if (newPosX + currentState.currentBlockWidth >= currentState.screenWidth) {
        newMovingRight = false;
      }
    } else {
      newPosX -= currentState.blockSpeed;
      // Check left boundary
      if (newPosX <= 0) {
        newMovingRight = true;
      }
    }

    return Right(currentState.copyWith(
      currentBlockPosX: newPosX,
      movingRight: newMovingRight,
    ));
  }
}
