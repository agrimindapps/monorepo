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

/// Use case to update snake position (game physics)
@injectable
class UpdateSnakePositionUseCase {
  final FoodGeneratorService _foodGeneratorService;

  UpdateSnakePositionUseCase(this._foodGeneratorService);

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
    final currentHead = currentState.head;
    Position newHead;

    switch (currentState.direction) {
      case Direction.up:
        newHead = Position(currentHead.x, currentHead.y - 1);
        break;
      case Direction.down:
        newHead = Position(currentHead.x, currentHead.y + 1);
        break;
      case Direction.left:
        newHead = Position(currentHead.x - 1, currentHead.y);
        break;
      case Direction.right:
        newHead = Position(currentHead.x + 1, currentHead.y);
        break;
    }

    // 2. Wraparound (snake goes through walls)
    newHead = Position(
      (newHead.x + currentState.gridSize) % currentState.gridSize,
      (newHead.y + currentState.gridSize) % currentState.gridSize,
    );

    // 3. Check collision with own body
    if (currentState.snake.contains(newHead)) {
      return Right(currentState.copyWith(
        gameStatus: SnakeGameStatus.gameOver,
      ));
    }

    // 4. Check if ate food
    final bool ateFood = newHead == currentState.foodPosition;

    // 5. Build new snake
    List<Position> newSnake = [newHead, ...currentState.snake];

    if (!ateFood) {
      // Remove tail if didn't eat
      newSnake = newSnake.sublist(0, newSnake.length - 1);
    }

    // 6. Generate new food position if ate (using cached free positions)
    Position newFoodPosition = currentState.foodPosition;
    Set<Position> newFreePositions = currentState.freePositions;

    if (ateFood) {
      // Remove eaten food position from free positions
      newFreePositions = {...currentState.freePositions}..remove(currentState.foodPosition);

      newFoodPosition = _foodGeneratorService.generateFood(
        snakeBody: newSnake,
        freePositions: newFreePositions,
        gridSize: currentState.gridSize,
      );

      // Add new food position to occupied (removing from free)
      newFreePositions.remove(newFoodPosition);
    }

    // 7. Update score
    final newScore = ateFood ? currentState.score + 1 : currentState.score;

    return Right(currentState.copyWith(
      snake: newSnake,
      foodPosition: newFoodPosition,
      score: newScore,
      freePositions: newFreePositions,
    ));
  }
}
