import 'dart:math';


import '../entities/position.dart';

/// Service responsible for food generation in snake game
///
/// Handles:
/// - Random food position generation
/// - Food validation (avoiding snake body)
/// - Food placement strategies
/// - Food statistics
class FoodGeneratorService {
  final Random _random;

  FoodGeneratorService({Random? random}) : _random = random ?? Random();

  // ============================================================================
  // Food Generation
  // ============================================================================

  /// Generates random food position avoiding snake body
  /// Uses cached free positions for better performance
  Position generateFood({
    required List<Position> snakeBody,
    required Set<Position> freePositions,
    required int gridSize,
    int maxAttempts = 100,
  }) {
    // If we have cached free positions, use them (O(1) lookup)
    if (freePositions.isNotEmpty) {
      final freeList = freePositions.toList();
      return freeList[_random.nextInt(freeList.length)];
    }

    // Fallback: try random generation
    Position foodPos;
    int attempts = 0;

    do {
      foodPos = _generateRandomPosition(gridSize);
      attempts++;
    } while (snakeBody.contains(foodPos) && attempts < maxAttempts);

    // If couldn't find free position in maxAttempts, recalculate (expensive)
    if (snakeBody.contains(foodPos)) {
      final calculatedFree = _getAllFreePositions(snakeBody, gridSize);
      if (calculatedFree.isNotEmpty) {
        foodPos = calculatedFree[_random.nextInt(calculatedFree.length)];
      }
    }

    return foodPos;
  }

  /// Generates random position within grid
  Position _generateRandomPosition(int gridSize) {
    return Position(
      _random.nextInt(gridSize),
      _random.nextInt(gridSize),
    );
  }

  /// Gets all free positions on grid
  List<Position> _getAllFreePositions(List<Position> snakeBody, int gridSize) {
    final freePositions = <Position>[];

    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final position = Position(x, y);
        if (!snakeBody.contains(position)) {
          freePositions.add(position);
        }
      }
    }

    return freePositions;
  }

  // ============================================================================
  // Strategic Food Placement
  // ============================================================================

  /// Generates food with strategic placement (far from snake head)
  Position generateStrategicFood({
    required List<Position> snakeBody,
    required int gridSize,
    required Position snakeHead,
  }) {
    final freePositions = _getAllFreePositions(snakeBody, gridSize);

    if (freePositions.isEmpty) {
      return _generateRandomPosition(gridSize);
    }

    // Sort by distance from head (furthest first)
    freePositions.sort((a, b) {
      final distA = _calculateManhattanDistance(snakeHead, a);
      final distB = _calculateManhattanDistance(snakeHead, b);
      return distB.compareTo(distA);
    });

    // Pick from top 25% furthest positions
    final topQuarter =
        (freePositions.length * 0.25).ceil().clamp(1, freePositions.length);
    final selectedIndex = _random.nextInt(topQuarter);

    return freePositions[selectedIndex];
  }

  /// Generates food near snake head (easier difficulty)
  Position generateNearbyFood({
    required List<Position> snakeBody,
    required int gridSize,
    required Position snakeHead,
    int maxDistance = 5,
  }) {
    final freePositions = _getAllFreePositions(snakeBody, gridSize);

    if (freePositions.isEmpty) {
      return _generateRandomPosition(gridSize);
    }

    // Filter positions within maxDistance
    final nearbyPositions = freePositions.where((pos) {
      final distance = _calculateManhattanDistance(snakeHead, pos);
      return distance <= maxDistance;
    }).toList();

    if (nearbyPositions.isEmpty) {
      return freePositions[_random.nextInt(freePositions.length)];
    }

    return nearbyPositions[_random.nextInt(nearbyPositions.length)];
  }

  // ============================================================================
  // Food Validation
  // ============================================================================

  /// Validates if food position is valid (not on snake)
  bool isFoodPositionValid({
    required Position foodPosition,
    required List<Position> snakeBody,
  }) {
    return !snakeBody.contains(foodPosition);
  }

  /// Gets food validation result
  FoodValidationResult validateFoodPosition({
    required Position foodPosition,
    required List<Position> snakeBody,
    required int gridSize,
  }) {
    final isValid = isFoodPositionValid(
      foodPosition: foodPosition,
      snakeBody: snakeBody,
    );

    final isWithinBounds = foodPosition.x >= 0 &&
        foodPosition.x < gridSize &&
        foodPosition.y >= 0 &&
        foodPosition.y < gridSize;

    return FoodValidationResult(
      isValid: isValid && isWithinBounds,
      isOnSnake: snakeBody.contains(foodPosition),
      isWithinBounds: isWithinBounds,
    );
  }

  // ============================================================================
  // Distance Calculations
  // ============================================================================

  /// Calculates Manhattan distance between two positions
  int _calculateManhattanDistance(Position from, Position to) {
    return (from.x - to.x).abs() + (from.y - to.y).abs();
  }

  /// Calculates distance from snake head to food
  int calculateDistanceToFood({
    required Position snakeHead,
    required Position foodPosition,
  }) {
    return _calculateManhattanDistance(snakeHead, foodPosition);
  }

  /// Calculates wrapped distance (considering grid wraparound)
  int calculateWrappedDistanceToFood({
    required Position snakeHead,
    required Position foodPosition,
    required int gridSize,
  }) {
    final dx = (snakeHead.x - foodPosition.x).abs();
    final dy = (snakeHead.y - foodPosition.y).abs();

    final wrappedDx = dx.clamp(0, gridSize - dx);
    final wrappedDy = dy.clamp(0, gridSize - dy);

    return wrappedDx + wrappedDy;
  }

  // ============================================================================
  // Food Difficulty
  // ============================================================================

  /// Gets food difficulty based on distance and grid occupancy
  FoodDifficulty getFoodDifficulty({
    required Position snakeHead,
    required Position foodPosition,
    required int gridSize,
    required int snakeLength,
  }) {
    final distance = calculateDistanceToFood(
      snakeHead: snakeHead,
      foodPosition: foodPosition,
    );

    final occupancy = snakeLength / (gridSize * gridSize);

    // Far + crowded = very hard
    if (distance > gridSize && occupancy > 0.5) {
      return FoodDifficulty.veryHard;
    }
    // Far or crowded = hard
    else if (distance > gridSize * 0.75 || occupancy > 0.4) {
      return FoodDifficulty.hard;
    }
    // Medium distance = medium
    else if (distance > gridSize * 0.5) {
      return FoodDifficulty.medium;
    }
    // Close = easy
    else {
      return FoodDifficulty.easy;
    }
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets food generation statistics
  FoodStatistics getStatistics({
    required Position snakeHead,
    required Position foodPosition,
    required List<Position> snakeBody,
    required int gridSize,
    required int totalFoodEaten,
  }) {
    final distance = calculateDistanceToFood(
      snakeHead: snakeHead,
      foodPosition: foodPosition,
    );

    final wrappedDistance = calculateWrappedDistanceToFood(
      snakeHead: snakeHead,
      foodPosition: foodPosition,
      gridSize: gridSize,
    );

    final difficulty = getFoodDifficulty(
      snakeHead: snakeHead,
      foodPosition: foodPosition,
      gridSize: gridSize,
      snakeLength: snakeBody.length,
    );

    final freePositions = _getAllFreePositions(snakeBody, gridSize);
    final availableSpaces = freePositions.length;

    return FoodStatistics(
      currentDistance: distance,
      wrappedDistance: wrappedDistance,
      difficulty: difficulty,
      totalFoodEaten: totalFoodEaten,
      availableSpaces: availableSpaces,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Food difficulty classification
enum FoodDifficulty {
  easy,
  medium,
  hard,
  veryHard;

  String get label {
    switch (this) {
      case FoodDifficulty.easy:
        return 'Easy to Reach';
      case FoodDifficulty.medium:
        return 'Medium Distance';
      case FoodDifficulty.hard:
        return 'Hard to Reach';
      case FoodDifficulty.veryHard:
        return 'Very Hard';
    }
  }
}

/// Food validation result
class FoodValidationResult {
  final bool isValid;
  final bool isOnSnake;
  final bool isWithinBounds;

  const FoodValidationResult({
    required this.isValid,
    required this.isOnSnake,
    required this.isWithinBounds,
  });

  String? get errorMessage {
    if (!isWithinBounds) {
      return 'Food position out of bounds';
    }
    if (isOnSnake) {
      return 'Food position on snake body';
    }
    return null;
  }
}

/// Food statistics
class FoodStatistics {
  final int currentDistance;
  final int wrappedDistance;
  final FoodDifficulty difficulty;
  final int totalFoodEaten;
  final int availableSpaces;

  const FoodStatistics({
    required this.currentDistance,
    required this.wrappedDistance,
    required this.difficulty,
    required this.totalFoodEaten,
    required this.availableSpaces,
  });

  /// Gets average food per available space
  double get foodDensity => totalFoodEaten / availableSpaces;

  /// Checks if space is getting tight
  bool get isSpaceTight => availableSpaces < 10;
}
