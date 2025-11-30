// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/position.dart';
import '../entities/enums.dart';
import '../services/food_generator_service.dart';
import '../services/snake_movement_service.dart';
import '../services/collision_detection_service.dart';
import '../services/power_up_service.dart';

/// Use case to update snake position (game physics)
class UpdateSnakePositionUseCase {
  final FoodGeneratorService _foodGeneratorService;
  final SnakeMovementService _movementService;
  final CollisionDetectionService _collisionService;
  final PowerUpService _powerUpService;

  UpdateSnakePositionUseCase(
    this._foodGeneratorService,
    this._movementService,
    this._collisionService,
    this._powerUpService,
  );

  /// Execute the use case
  /// Moves snake, checks collisions, checks food and power-ups
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeGameState currentState,
  }) async {
    // Validation: game must be running
    if (!currentState.gameStatus.isRunning) {
      return const Left(GameLogicFailure('Game is not running'));
    }

    // Update power-ups first (remove expired, apply effects)
    var updatedPowerUpsOnGrid = _powerUpService.cleanExpiredPowerUps(
      currentState.powerUpsOnGrid,
    );
    var updatedActivePowerUps = _powerUpService.updateActivePowerUps(
      currentState.activePowerUps,
    );

    // Apply magnet effect
    Position currentFoodPosition = currentState.foodPosition;
    final hasActiveMagnet = updatedActivePowerUps.any(
      (p) => p.type == PowerUpType.magnet && p.isActive,
    );
    if (hasActiveMagnet) {
      final magnetPosition = _powerUpService.applyMagnetEffect(
        snakeHead: currentState.head,
        foodPosition: currentFoodPosition,
        gridSize: currentState.gridSize,
        hasMagnet: true,
      );
      if (magnetPosition != null &&
          !currentState.snake.contains(magnetPosition)) {
        currentFoodPosition = magnetPosition;
      }
    }

    // 1. Calculate new head position based on direction
    final newHead = _movementService.moveHead(
      currentHead: currentState.head,
      direction: currentState.direction,
      gridSize: currentState.gridSize,
      hasWalls: currentState.hasWalls,
    );

    // 1.1 Check wall collision (if enabled)
    if (currentState.hasWalls) {
      if (!_movementService.isWithinBounds(
        position: newHead,
        gridSize: currentState.gridSize,
      )) {
        // Check if shield should block wall collision
        final hasActiveShield = updatedActivePowerUps.any(
          (p) => p.type == PowerUpType.shield && p.isActive,
        );
        if (hasActiveShield) {
          // Consume shield and continue (stay in place)
          updatedActivePowerUps = _powerUpService.consumeShield(updatedActivePowerUps);
          return Right(currentState.copyWith(
            activePowerUps: updatedActivePowerUps,
            powerUpsOnGrid: updatedPowerUpsOnGrid,
            foodPosition: currentFoodPosition,
          ));
        }
        return Right(currentState.copyWith(gameStatus: SnakeGameStatus.gameOver));
      }
    }

    // 2. Check collision with own body
    final collisionResult = _collisionService.checkCollision(
      headPosition: newHead,
      snakeBody: currentState.snake,
    );

    if (collisionResult.hasCollision) {
      // Check if should ignore collision (shield or ghost mode)
      final shouldIgnore = _powerUpService.shouldIgnoreCollision(
        activePowerUps: updatedActivePowerUps,
        isSelfCollision: true,
        isWallCollision: false,
      );

      if (shouldIgnore) {
        // Check if it's shield (consume) or ghost (keep)
        final hasActiveShield = updatedActivePowerUps.any(
          (p) => p.type == PowerUpType.shield && p.isActive,
        );
        final hasGhostMode = updatedActivePowerUps.any(
          (p) => p.type == PowerUpType.ghostMode && p.isActive,
        );

        if (hasActiveShield && !hasGhostMode) {
          // Consume shield
          updatedActivePowerUps = _powerUpService.consumeShield(updatedActivePowerUps);
        }
        // Continue without game over
      } else {
        return Right(currentState.copyWith(gameStatus: SnakeGameStatus.gameOver));
      }
    }

    // 3. Check if collected power-up
    final collectedPowerUp = _powerUpService.checkPowerUpCollision(
      headPosition: newHead,
      powerUpsOnGrid: updatedPowerUpsOnGrid,
    );

    if (collectedPowerUp != null) {
      // Remove from grid and activate
      updatedPowerUpsOnGrid = _powerUpService.removePowerUpFromGrid(
        updatedPowerUpsOnGrid,
        collectedPowerUp.id,
      );
      updatedActivePowerUps = _powerUpService.activatePowerUp(
        updatedActivePowerUps,
        collectedPowerUp.type,
      );
    }

    // 4. Check if ate food
    final foodCollision = _collisionService.checkFood(
      headPosition: newHead,
      foodPosition: currentFoodPosition,
    );
    final ateFood = foodCollision.ateFood;

    // 5. Build new snake
    final newSnake = _movementService.updateSnakeBody(
      currentSnake: currentState.snake,
      newHead: newHead,
      ateFood: ateFood,
    );

    // 6. Generate new food position if ate (using cached free positions)
    Position newFoodPosition = currentFoodPosition;
    Set<Position> newFreePositions = currentState.freePositions;

    if (ateFood) {
      // Remove eaten food position from free positions
      newFreePositions = {...currentState.freePositions}
        ..remove(currentFoodPosition);

      newFoodPosition = _foodGeneratorService.generateFood(
        snakeBody: newSnake,
        freePositions: newFreePositions,
        gridSize: currentState.gridSize,
      );

      // Add new food position to occupied (removing from free)
      newFreePositions.remove(newFoodPosition);

      // Try to spawn power-up after eating food
      final newPowerUp = _powerUpService.maybeSpawnPowerUp(
        score: currentState.score,
        snakeBody: newSnake,
        freePositions: newFreePositions,
        foodPosition: newFoodPosition,
        existingPowerUps: updatedPowerUpsOnGrid,
        spawnChance: 0.15,
      );

      if (newPowerUp != null) {
        updatedPowerUpsOnGrid = [...updatedPowerUpsOnGrid, newPowerUp];
      }
    }

    // 7. Update score with multiplier
    final hasDoublePoints = updatedActivePowerUps.any(
      (p) => p.type == PowerUpType.doublePoints && p.isActive,
    );
    final scoreIncrease = ateFood
        ? _powerUpService.calculateScore(
            baseScore: 1,
            hasDoublePoints: hasDoublePoints,
          )
        : 0;
    final newScore = currentState.score + scoreIncrease;

    return Right(
      currentState.copyWith(
        snake: newSnake,
        foodPosition: newFoodPosition,
        score: newScore,
        freePositions: newFreePositions,
        powerUpsOnGrid: updatedPowerUpsOnGrid,
        activePowerUps: updatedActivePowerUps,
      ),
    );
  }
}
