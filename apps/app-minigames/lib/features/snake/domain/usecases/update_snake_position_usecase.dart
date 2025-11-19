// Package imports:
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Core imports:
import 'package:app_minigames/core/error/failures.dart';

// Domain imports:
import '../entities/game_state.dart';
import '../entities/position.dart';
import '../entities/enums.dart';
import '../services/food_generator_service.dart';
import '../services/snake_movement_service.dart';
import '../services/collision_detection_service.dart';

/// Use case to update snake position (game physics)
@injectable
class UpdateSnakePositionUseCase {
  final FoodGeneratorService _foodGeneratorService;
  final SnakeMovementService _movementService;
  final CollisionDetectionService _collisionService;

  UpdateSnakePositionUseCase(
    this._foodGeneratorService,
    this._movementService,
    this._collisionService,
  );

  /// Execute the use case
  /// Moves snake, checks collisions, checks food
  Future<Either<Failure, SnakeGameState>> call({
    required SnakeGameState currentState,
  }) async {
    // Validation: game must be running
    if (!currentState.gameStatus.isRunning) {
      return Left(GameLogicFailure('Game is not running'));
    }

    // 1. Calculate new head position based on direction
    final newHead = _movementService.moveHead(
      currentHead: currentState.head,
      direction: currentState.direction,
      gridSize: currentState.gridSize,
    );

    // 2. Check collision with own body
    final collisionResult = _collisionService.checkCollision(
      headPosition: newHead,
      snakeBody: currentState.snake,
    );

    if (collisionResult.hasCollision) {
      return Right(currentState.copyWith(gameStatus: SnakeGameStatus.gameOver));
    }

    // 3. Check if ate food
    final foodCollision = _collisionService.checkFood(
      headPosition: newHead,
      foodPosition: currentState.foodPosition,
    );
    final ateFood = foodCollision.ateFood;

    // 4. Build new snake
    final newSnake = _movementService.updateSnakeBody(
      currentSnake: currentState.snake,
      newHead: newHead,
      ateFood: ateFood,
    );

    // 5. Generate new food position if ate (using cached free positions)
    Position newFoodPosition = currentState.foodPosition;
    Set<Position> newFreePositions = currentState.freePositions;

    if (ateFood) {
      // Remove eaten food position from free positions
      newFreePositions = {...currentState.freePositions}
        ..remove(currentState.foodPosition);

      newFoodPosition = _foodGeneratorService.generateFood(
        snakeBody: newSnake,
        freePositions: newFreePositions,
        gridSize: currentState.gridSize,
      );

      // Add new food position to occupied (removing from free)
      newFreePositions.remove(newFoodPosition);
    }

    // 6. Update score
    final newScore = ateFood ? currentState.score + 1 : currentState.score;

    return Right(
      currentState.copyWith(
        snake: newSnake,
        foodPosition: newFoodPosition,
        score: newScore,
        freePositions: newFreePositions,
      ),
    );
  }
}
