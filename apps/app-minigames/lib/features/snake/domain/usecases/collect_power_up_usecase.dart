// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/power_up.dart';
import '../services/power_up_service.dart';

/// Use case to collect a power-up from the grid
class CollectPowerUpUseCase {
  final PowerUpService _powerUpService;

  CollectPowerUpUseCase(this._powerUpService);

  /// Execute the use case
  /// Collects power-up and activates its effect
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeGameState currentState,
    required PowerUp powerUp,
  }) async {
    // Validation
    if (!currentState.gameStatus.isRunning) {
      return Left(GameLogicFailure('Game is not running'));
    }

    // Remove power-up from grid
    final updatedGridPowerUps = _powerUpService.removePowerUpFromGrid(
      currentState.powerUpsOnGrid,
      powerUp.id,
    );

    // Activate power-up effect
    final updatedActivePowerUps = _powerUpService.activatePowerUp(
      currentState.activePowerUps,
      powerUp.type,
    );

    return Right(
      currentState.copyWith(
        powerUpsOnGrid: updatedGridPowerUps,
        activePowerUps: updatedActivePowerUps,
      ),
    );
  }
}
