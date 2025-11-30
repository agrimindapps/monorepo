// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/position.dart';
import '../services/power_up_service.dart';

/// Use case to update power-up states each game tick
class UpdatePowerUpsUseCase {
  final PowerUpService _powerUpService;

  UpdatePowerUpsUseCase(this._powerUpService);

  /// Execute the use case
  /// Updates power-ups: removes expired from grid and deactivates expired effects
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeGameState currentState,
  }) async {
    // Validation
    if (!currentState.gameStatus.isRunning) {
      return const Left(GameLogicFailure('Game is not running'));
    }

    // Clean expired power-ups from grid
    final cleanedGridPowerUps = _powerUpService.cleanExpiredPowerUps(
      currentState.powerUpsOnGrid,
    );

    // Update active power-ups (remove expired)
    final updatedActivePowerUps = _powerUpService.updateActivePowerUps(
      currentState.activePowerUps,
    );

    // Apply magnet effect if active
    Position newFoodPosition = currentState.foodPosition;
    if (currentState.hasMagnet) {
      final magnetPosition = _powerUpService.applyMagnetEffect(
        snakeHead: currentState.head,
        foodPosition: currentState.foodPosition,
        gridSize: currentState.gridSize,
        hasMagnet: true,
      );
      if (magnetPosition != null && 
          !currentState.snake.contains(magnetPosition)) {
        newFoodPosition = magnetPosition;
      }
    }

    return Right(
      currentState.copyWith(
        powerUpsOnGrid: cleanedGridPowerUps,
        activePowerUps: updatedActivePowerUps,
        foodPosition: newFoodPosition,
      ),
    );
  }
}
