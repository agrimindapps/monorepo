
import '../entities/position.dart';

/// Service responsible for collision detection in snake game
///
/// Handles:
/// - Self-collision detection (snake hitting itself)
/// - Food collision detection
/// - Boundary checks
/// - Collision predictions
class CollisionDetectionService {
  CollisionDetectionService();

  // ============================================================================
  // Self-Collision Detection
  // ============================================================================

  /// Checks if head position collides with snake body
  bool checkSelfCollision({
    required Position headPosition,
    required List<Position> snakeBody,
  }) {
    return snakeBody.contains(headPosition);
  }

  /// Checks if snake would collide with itself at new position
  bool wouldCollideWithSelf({
    required Position newHeadPosition,
    required List<Position> currentSnake,
  }) {
    return currentSnake.contains(newHeadPosition);
  }

  /// Gets collision result with detailed information
  CollisionResult checkCollision({
    required Position headPosition,
    required List<Position> snakeBody,
  }) {
    final hasCollision = checkSelfCollision(
      headPosition: headPosition,
      snakeBody: snakeBody,
    );

    if (hasCollision) {
      final collisionIndex = snakeBody.indexOf(headPosition);
      return CollisionResult(
        hasCollision: true,
        collisionType: CollisionType.self,
        collisionPosition: headPosition,
        collisionIndex: collisionIndex,
      );
    }

    return const CollisionResult(
      hasCollision: false,
      collisionType: CollisionType.none,
      collisionPosition: null,
      collisionIndex: null,
    );
  }

  // ============================================================================
  // Food Collision Detection
  // ============================================================================

  /// Checks if head position is at food position
  bool checkFoodCollision({
    required Position headPosition,
    required Position foodPosition,
  }) {
    return headPosition == foodPosition;
  }

  /// Gets food collision result
  FoodCollisionResult checkFood({
    required Position headPosition,
    required Position foodPosition,
  }) {
    final ateFood = checkFoodCollision(
      headPosition: headPosition,
      foodPosition: foodPosition,
    );

    return FoodCollisionResult(
      ateFood: ateFood,
      foodPosition: foodPosition,
    );
  }

  // ============================================================================
  // Position Validation
  // ============================================================================

  /// Checks if position is occupied by snake
  bool isPositionOccupied({
    required Position position,
    required List<Position> snakeBody,
  }) {
    return snakeBody.contains(position);
  }

  /// Checks if position is free (not occupied by snake)
  bool isPositionFree({
    required Position position,
    required List<Position> snakeBody,
  }) {
    return !isPositionOccupied(
      position: position,
      snakeBody: snakeBody,
    );
  }

  /// Gets all free positions on grid
  List<Position> getFreePositions({
    required List<Position> snakeBody,
    required int gridSize,
  }) {
    final freePositions = <Position>[];

    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final position = Position(x, y);
        if (isPositionFree(position: position, snakeBody: snakeBody)) {
          freePositions.add(position);
        }
      }
    }

    return freePositions;
  }

  // ============================================================================
  // Collision Prediction
  // ============================================================================

  /// Predicts if snake will collide in next N moves
  CollisionPrediction predictCollision({
    required List<Position> snakeBody,
    required Position nextHeadPosition,
    int movesAhead = 1,
  }) {
    // For now, just check next move
    final willCollide = wouldCollideWithSelf(
      newHeadPosition: nextHeadPosition,
      currentSnake: snakeBody,
    );

    return CollisionPrediction(
      willCollide: willCollide,
      movesUntilCollision: willCollide ? 1 : null,
      dangerLevel: _calculateDangerLevel(snakeBody, nextHeadPosition),
    );
  }

  /// Calculates danger level based on surrounding positions
  DangerLevel _calculateDangerLevel(
    List<Position> snakeBody,
    Position position,
  ) {
    // Simple heuristic: count adjacent body parts
    int adjacentBodyParts = 0;

    // Check all 4 directions
    final adjacentPositions = [
      Position(position.x, position.y - 1), // up
      Position(position.x, position.y + 1), // down
      Position(position.x - 1, position.y), // left
      Position(position.x + 1, position.y), // right
    ];

    for (final adjPos in adjacentPositions) {
      if (snakeBody.contains(adjPos)) {
        adjacentBodyParts++;
      }
    }

    if (adjacentBodyParts >= 3) {
      return DangerLevel.critical;
    } else if (adjacentBodyParts == 2) {
      return DangerLevel.high;
    } else if (adjacentBodyParts == 1) {
      return DangerLevel.medium;
    } else {
      return DangerLevel.low;
    }
  }

  // ============================================================================
  // Distance Calculations
  // ============================================================================

  /// Calculates Manhattan distance between two positions
  int calculateManhattanDistance({
    required Position from,
    required Position to,
  }) {
    return (from.x - to.x).abs() + (from.y - to.y).abs();
  }

  /// Calculates Manhattan distance with grid wraparound
  int calculateWrappedDistance({
    required Position from,
    required Position to,
    required int gridSize,
  }) {
    final dx = (from.x - to.x).abs();
    final dy = (from.y - to.y).abs();

    // Consider wraparound
    final wrappedDx = dx.clamp(0, gridSize - dx);
    final wrappedDy = dy.clamp(0, gridSize - dy);

    return wrappedDx + wrappedDy;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets collision statistics
  CollisionStatistics getStatistics({
    required List<Position> snakeBody,
    required int gridSize,
    required Position headPosition,
  }) {
    final freePositions = getFreePositions(
      snakeBody: snakeBody,
      gridSize: gridSize,
    );

    final occupiedPositions = gridSize * gridSize - freePositions.length;
    final occupancyPercentage =
        (occupiedPositions / (gridSize * gridSize)) * 100;

    final prediction = predictCollision(
      snakeBody: snakeBody.sublist(1), // exclude head
      nextHeadPosition: headPosition,
    );

    return CollisionStatistics(
      freePositions: freePositions.length,
      occupiedPositions: occupiedPositions,
      occupancyPercentage: occupancyPercentage,
      dangerLevel: prediction.dangerLevel,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Type of collision
enum CollisionType {
  none,
  self,
  wall; // For future use if walls are added

  String get label {
    switch (this) {
      case CollisionType.none:
        return 'No Collision';
      case CollisionType.self:
        return 'Self Collision';
      case CollisionType.wall:
        return 'Wall Collision';
    }
  }
}

/// Danger level classification
enum DangerLevel {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case DangerLevel.low:
        return 'Low Danger';
      case DangerLevel.medium:
        return 'Medium Danger';
      case DangerLevel.high:
        return 'High Danger';
      case DangerLevel.critical:
        return 'Critical Danger';
    }
  }
}

/// Result of collision check
class CollisionResult {
  final bool hasCollision;
  final CollisionType collisionType;
  final Position? collisionPosition;
  final int? collisionIndex; // Index in snake body where collision occurred

  const CollisionResult({
    required this.hasCollision,
    required this.collisionType,
    required this.collisionPosition,
    required this.collisionIndex,
  });

  /// Gets collision message
  String get message {
    if (!hasCollision) {
      return 'No collision';
    }
    return '${collisionType.label} at position (${collisionPosition?.x}, ${collisionPosition?.y})';
  }
}

/// Result of food collision check
class FoodCollisionResult {
  final bool ateFood;
  final Position foodPosition;

  const FoodCollisionResult({
    required this.ateFood,
    required this.foodPosition,
  });

  String get message => ateFood ? 'Food eaten!' : 'No food eaten';
}

/// Collision prediction result
class CollisionPrediction {
  final bool willCollide;
  final int? movesUntilCollision;
  final DangerLevel dangerLevel;

  const CollisionPrediction({
    required this.willCollide,
    required this.movesUntilCollision,
    required this.dangerLevel,
  });
}

/// Collision statistics
class CollisionStatistics {
  final int freePositions;
  final int occupiedPositions;
  final double occupancyPercentage;
  final DangerLevel dangerLevel;

  const CollisionStatistics({
    required this.freePositions,
    required this.occupiedPositions,
    required this.occupancyPercentage,
    required this.dangerLevel,
  });

  /// Checks if grid is mostly occupied (> 75%)
  bool get isCrowded => occupancyPercentage > 75;

  /// Checks if grid is nearly full (> 90%)
  bool get isNearlyFull => occupancyPercentage > 90;
}
