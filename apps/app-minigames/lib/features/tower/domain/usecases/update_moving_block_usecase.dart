import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../services/physics_service.dart';

/// Use case for updating the moving block's position
/// Delegates physics calculations to PhysicsService
class UpdateMovingBlockUseCase {
  final PhysicsService _physicsService;

  UpdateMovingBlockUseCase(this._physicsService);

  Either<Failure, GameState> call(GameState currentState) {
    // Don't update if paused or game over
    if (currentState.isPaused || currentState.isGameOver) {
      return Right(currentState);
    }

    // Calculate new position using physics service
    final physicsResult = _physicsService.updatePosition(
      currentPosX: currentState.currentBlockPosX,
      blockWidth: currentState.currentBlockWidth,
      blockSpeed: currentState.blockSpeed,
      movingRight: currentState.movingRight,
      screenWidth: currentState.screenWidth,
    );

    return Right(currentState.copyWith(
      currentBlockPosX: physicsResult.newPosX,
      movingRight: physicsResult.newMovingRight,
    ));
  }
}
