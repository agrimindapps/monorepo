// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../services/power_up_service.dart';

/// Use case to spawn a power-up after eating food
class SpawnPowerUpUseCase {
  final PowerUpService _powerUpService;

  SpawnPowerUpUseCase(this._powerUpService);

  /// Execute the use case
  /// Attempts to spawn a power-up with given probability
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeGameState currentState,
    double spawnChance = 0.15,
  }) async {
    // Validation
    if (!currentState.gameStatus.isRunning) {
      return Left(GameLogicFailure('Game is not running'));
    }

    // Try to spawn power-up
    final newPowerUp = _powerUpService.maybeSpawnPowerUp(
      score: currentState.score,
      snakeBody: currentState.snake,
      freePositions: currentState.freePositions,
      foodPosition: currentState.foodPosition,
      existingPowerUps: currentState.powerUpsOnGrid,
      spawnChance: spawnChance,
    );

    if (newPowerUp == null) {
      // No power-up spawned, return unchanged state
      return Right(currentState);
    }

    // Add new power-up to grid
    final updatedPowerUps = [...currentState.powerUpsOnGrid, newPowerUp];

    return Right(
      currentState.copyWith(powerUpsOnGrid: updatedPowerUps),
    );
  }
}
