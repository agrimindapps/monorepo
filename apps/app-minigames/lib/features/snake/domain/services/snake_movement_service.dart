import 'package:injectable/injectable.dart';

import '../entities/enums.dart';
import '../entities/position.dart';

/// Service responsible for snake movement physics
///
/// Handles:
/// - Head position calculation based on direction
/// - Grid wraparound (passing through walls)
/// - Movement validation
/// - Speed calculations
@lazySingleton
class SnakeMovementService {
  SnakeMovementService();

  // ============================================================================
  // Head Position Calculation
  // ============================================================================

  /// Calculates new head position based on current direction
  Position calculateNewHeadPosition({
    required Position currentHead,
    required Direction direction,
  }) {
    switch (direction) {
      case Direction.up:
        return Position(currentHead.x, currentHead.y - 1);
      case Direction.down:
        return Position(currentHead.x, currentHead.y + 1);
      case Direction.left:
        return Position(currentHead.x - 1, currentHead.y);
      case Direction.right:
        return Position(currentHead.x + 1, currentHead.y);
    }
  }

  /// Applies wraparound to position (snake passes through walls)
  Position applyWraparound({
    required Position position,
    required int gridSize,
  }) {
    return Position(
      (position.x + gridSize) % gridSize,
      (position.y + gridSize) % gridSize,
    );
  }

  /// Calculates new head with direction and wraparound applied
  Position moveHead({
    required Position currentHead,
    required Direction direction,
    required int gridSize,
  }) {
    final newHead = calculateNewHeadPosition(
      currentHead: currentHead,
      direction: direction,
    );

    return applyWraparound(
      position: newHead,
      gridSize: gridSize,
    );
  }

  // ============================================================================
  // Snake Body Update
  // ============================================================================

  /// Updates snake body after movement
  /// If ate food, snake grows; otherwise tail is removed
  List<Position> updateSnakeBody({
    required List<Position> currentSnake,
    required Position newHead,
    required bool ateFood,
  }) {
    final newSnake = [newHead, ...currentSnake];

    if (!ateFood) {
      // Remove tail if didn't eat
      return newSnake.sublist(0, newSnake.length - 1);
    }

    return newSnake;
  }

  // ============================================================================
  // Direction Validation
  // ============================================================================

  /// Validates if new direction is valid (not opposite)
  bool isValidDirection({
    required Direction currentDirection,
    required Direction newDirection,
  }) {
    return !_isOppositeDirection(currentDirection, newDirection);
  }

  /// Checks if two directions are opposite
  bool _isOppositeDirection(Direction current, Direction target) {
    return (current == Direction.up && target == Direction.down) ||
        (current == Direction.down && target == Direction.up) ||
        (current == Direction.left && target == Direction.right) ||
        (current == Direction.right && target == Direction.left);
  }

  /// Gets direction validation result
  DirectionValidationResult validateDirectionChange({
    required Direction currentDirection,
    required Direction newDirection,
  }) {
    final isValid = isValidDirection(
      currentDirection: currentDirection,
      newDirection: newDirection,
    );

    return DirectionValidationResult(
      isValid: isValid,
      errorMessage: isValid ? null : 'Cannot go in opposite direction',
    );
  }

  // ============================================================================
  // Movement Information
  // ============================================================================

  /// Gets movement delta for a direction
  MovementDelta getMovementDelta(Direction direction) {
    switch (direction) {
      case Direction.up:
        return const MovementDelta(dx: 0, dy: -1);
      case Direction.down:
        return const MovementDelta(dx: 0, dy: 1);
      case Direction.left:
        return const MovementDelta(dx: -1, dy: 0);
      case Direction.right:
        return const MovementDelta(dx: 1, dy: 0);
    }
  }

  /// Checks if position is within grid bounds (before wraparound)
  bool isWithinBounds({
    required Position position,
    required int gridSize,
  }) {
    return position.x >= 0 &&
        position.x < gridSize &&
        position.y >= 0 &&
        position.y < gridSize;
  }

  /// Gets all positions adjacent to current position
  List<Position> getAdjacentPositions({
    required Position position,
    required int gridSize,
  }) {
    final adjacents = <Position>[];

    for (final direction in Direction.values) {
      final newPos = calculateNewHeadPosition(
        currentHead: position,
        direction: direction,
      );
      final wrapped = applyWraparound(
        position: newPos,
        gridSize: gridSize,
      );
      adjacents.add(wrapped);
    }

    return adjacents;
  }

  // ============================================================================
  // Speed Calculations
  // ============================================================================

  /// Gets game speed in milliseconds for difficulty
  int getGameSpeedMs(SnakeDifficulty difficulty) {
    return difficulty.gameSpeed.inMilliseconds;
  }

  /// Gets moves per second for difficulty
  double getMovesPerSecond(SnakeDifficulty difficulty) {
    final ms = getGameSpeedMs(difficulty);
    return 1000 / ms;
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Gets movement statistics
  MovementStatistics getStatistics({
    required int totalMoves,
    required int gridSize,
    required SnakeDifficulty difficulty,
  }) {
    final movesPerSecond = getMovesPerSecond(difficulty);
    final secondsPlayed = totalMoves / movesPerSecond;
    final gridCoverage = totalMoves / (gridSize * gridSize);

    return MovementStatistics(
      totalMoves: totalMoves,
      movesPerSecond: movesPerSecond,
      secondsPlayed: secondsPlayed,
      gridCoverage: gridCoverage,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of direction validation
class DirectionValidationResult {
  final bool isValid;
  final String? errorMessage;

  const DirectionValidationResult({
    required this.isValid,
    required this.errorMessage,
  });
}

/// Movement delta (change in x and y)
class MovementDelta {
  final int dx;
  final int dy;

  const MovementDelta({
    required this.dx,
    required this.dy,
  });
}

/// Movement statistics
class MovementStatistics {
  final int totalMoves;
  final double movesPerSecond;
  final double secondsPlayed;
  final double gridCoverage;

  const MovementStatistics({
    required this.totalMoves,
    required this.movesPerSecond,
    required this.secondsPlayed,
    required this.gridCoverage,
  });

  /// Gets minutes played
  double get minutesPlayed => secondsPlayed / 60;

  /// Gets grid coverage as percentage
  double get gridCoveragePercentage => gridCoverage * 100;
}
