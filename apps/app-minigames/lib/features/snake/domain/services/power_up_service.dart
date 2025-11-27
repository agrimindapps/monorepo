import 'dart:math';

import '../entities/enums.dart';
import '../entities/position.dart';
import '../entities/power_up.dart';

/// Service responsible for power-up management in snake game
///
/// Handles:
/// - Power-up spawning with probability
/// - Power-up type selection based on score
/// - Active power-up updates
/// - Power-up effects on game mechanics
class PowerUpService {
  final Random _random;

  PowerUpService({Random? random}) : _random = random ?? Random();

  // ============================================================================
  // Power-Up Spawning
  // ============================================================================

  /// Maybe spawn a power-up with given probability
  /// Returns null if no power-up should spawn
  PowerUp? maybeSpawnPowerUp({
    required int score,
    required List<Position> snakeBody,
    required Set<Position> freePositions,
    required Position foodPosition,
    required List<PowerUp> existingPowerUps,
    double spawnChance = 0.15,
  }) {
    // Max 2 power-ups on grid
    if (existingPowerUps.length >= 2) return null;

    // Roll for spawn chance
    if (_random.nextDouble() > spawnChance) return null;

    // Get available positions (not on snake, food, or existing power-ups)
    final occupiedByPowerUps = existingPowerUps.map((p) => p.position).toSet();
    final availablePositions = freePositions
        .where((p) => p != foodPosition && !occupiedByPowerUps.contains(p))
        .toList();

    if (availablePositions.isEmpty) return null;

    // Select position
    final position = availablePositions[_random.nextInt(availablePositions.length)];

    // Select type based on score
    final type = selectPowerUpType(
      score: score,
      activePowerUps: const [],
    );

    return PowerUp(
      id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      position: position,
      spawnedAt: DateTime.now(),
      lifetime: const Duration(seconds: 10),
    );
  }

  /// Select power-up type based on score and current active power-ups
  /// Different probabilities based on game progress
  PowerUpType selectPowerUpType({
    required int score,
    required List<ActivePowerUp> activePowerUps,
  }) {
    // Define weights based on score ranges
    final Map<PowerUpType, double> weights;

    if (score < 10) {
      // Early game: favor easier power-ups
      weights = {
        PowerUpType.doublePoints: 0.30,
        PowerUpType.slowMotion: 0.30,
        PowerUpType.shield: 0.20,
        PowerUpType.magnet: 0.10,
        PowerUpType.speedBoost: 0.05,
        PowerUpType.ghostMode: 0.05,
      };
    } else if (score <= 30) {
      // Mid game: balanced
      weights = {
        PowerUpType.doublePoints: 0.20,
        PowerUpType.slowMotion: 0.15,
        PowerUpType.shield: 0.20,
        PowerUpType.magnet: 0.15,
        PowerUpType.speedBoost: 0.15,
        PowerUpType.ghostMode: 0.15,
      };
    } else {
      // Late game: more challenging power-ups
      weights = {
        PowerUpType.doublePoints: 0.10,
        PowerUpType.slowMotion: 0.10,
        PowerUpType.shield: 0.15,
        PowerUpType.magnet: 0.15,
        PowerUpType.speedBoost: 0.25,
        PowerUpType.ghostMode: 0.25,
      };
    }

    // Reduce weight for already active power-up types
    final activeTypes = activePowerUps.map((p) => p.type).toSet();
    final adjustedWeights = Map<PowerUpType, double>.from(weights);
    for (final type in activeTypes) {
      adjustedWeights[type] = (adjustedWeights[type] ?? 0) * 0.3;
    }

    // Normalize weights
    final totalWeight = adjustedWeights.values.reduce((a, b) => a + b);
    final normalizedWeights = adjustedWeights.map(
      (type, weight) => MapEntry(type, weight / totalWeight),
    );

    // Random selection based on weights
    final roll = _random.nextDouble();
    double cumulative = 0;

    for (final entry in normalizedWeights.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) {
        return entry.key;
      }
    }

    // Fallback
    return PowerUpType.doublePoints;
  }

  // ============================================================================
  // Active Power-Up Management
  // ============================================================================

  /// Update active power-ups, removing expired ones
  List<ActivePowerUp> updateActivePowerUps(List<ActivePowerUp> current) {
    return current.where((p) => p.isActive).toList();
  }

  /// Clean expired power-ups from the grid
  List<PowerUp> cleanExpiredPowerUps(List<PowerUp> powerUps) {
    return powerUps.where((p) => !p.isExpired).toList();
  }

  /// Activate a power-up (add to active list)
  List<ActivePowerUp> activatePowerUp(
    List<ActivePowerUp> current,
    PowerUpType type,
  ) {
    // Remove existing power-up of same type (reset duration)
    final filtered = current.where((p) => p.type != type).toList();
    // Add new activation
    return [...filtered, ActivePowerUp.fromType(type)];
  }

  // ============================================================================
  // Power-Up Effects
  // ============================================================================

  /// Calculate game speed with power-up effects
  /// Returns speed in milliseconds
  int calculateSpeedWithPowerUps({
    required int baseSpeed,
    required bool hasSpeedBoost,
    required bool hasSlowMotion,
  }) {
    double multiplier = 1.0;

    if (hasSpeedBoost) {
      // 50% faster = 0.67x time between moves
      multiplier *= 0.67;
    }

    if (hasSlowMotion) {
      // 30% slower = 1.43x time between moves
      multiplier *= 1.43;
    }

    return (baseSpeed * multiplier).round().clamp(8, 200);
  }

  /// Calculate score with power-up multiplier
  int calculateScore({
    required int baseScore,
    required bool hasDoublePoints,
  }) {
    return hasDoublePoints ? baseScore * 2 : baseScore;
  }

  /// Check if collision should be ignored based on active power-ups
  bool shouldIgnoreCollision({
    required List<ActivePowerUp> activePowerUps,
    required bool isSelfCollision,
    required bool isWallCollision,
  }) {
    // Shield ignores one collision (both self and wall)
    final hasShield = activePowerUps.any(
      (p) => p.type == PowerUpType.shield && p.isActive,
    );

    // Ghost mode only ignores self-collision
    final hasGhostMode = activePowerUps.any(
      (p) => p.type == PowerUpType.ghostMode && p.isActive,
    );

    if (isSelfCollision) {
      return hasShield || hasGhostMode;
    }

    if (isWallCollision) {
      return hasShield;
    }

    return false;
  }

  /// Apply magnet effect - move food closer to snake head
  /// Returns new food position or null if no change
  Position? applyMagnetEffect({
    required Position snakeHead,
    required Position foodPosition,
    required int gridSize,
    required bool hasMagnet,
  }) {
    if (!hasMagnet) return null;

    // Calculate direction toward snake head
    final dx = snakeHead.x - foodPosition.x;
    final dy = snakeHead.y - foodPosition.y;

    // Move 1 cell closer
    int newX = foodPosition.x;
    int newY = foodPosition.y;

    if (dx.abs() > dy.abs()) {
      // Move horizontally
      newX += dx.sign;
    } else if (dy != 0) {
      // Move vertically
      newY += dy.sign;
    }

    // Clamp to grid bounds
    newX = newX.clamp(0, gridSize - 1);
    newY = newY.clamp(0, gridSize - 1);

    final newPosition = Position(newX, newY);

    // Don't move to same position as head
    if (newPosition == snakeHead) {
      return null;
    }

    return newPosition;
  }

  // ============================================================================
  // Collision Detection with Power-Ups
  // ============================================================================

  /// Check if snake head collides with any power-up on grid
  PowerUp? checkPowerUpCollision({
    required Position headPosition,
    required List<PowerUp> powerUpsOnGrid,
  }) {
    try {
      return powerUpsOnGrid.firstWhere((p) => p.position == headPosition);
    } catch (_) {
      return null;
    }
  }

  /// Remove collected power-up from grid
  List<PowerUp> removePowerUpFromGrid(
    List<PowerUp> powerUps,
    String powerUpId,
  ) {
    return powerUps.where((p) => p.id != powerUpId).toList();
  }

  // ============================================================================
  // Shield Consumption
  // ============================================================================

  /// Consume shield (remove from active list after blocking collision)
  List<ActivePowerUp> consumeShield(List<ActivePowerUp> activePowerUps) {
    return activePowerUps.where((p) => p.type != PowerUpType.shield).toList();
  }

  // ============================================================================
  // Statistics
  // ============================================================================

  /// Get power-up statistics for display
  PowerUpStatistics getStatistics({
    required List<PowerUp> powerUpsOnGrid,
    required List<ActivePowerUp> activePowerUps,
  }) {
    return PowerUpStatistics(
      powerUpsOnGrid: powerUpsOnGrid.length,
      activePowerUps: activePowerUps.length,
      activeTypes: activePowerUps.map((p) => p.type).toList(),
      hasSpeedModifier: activePowerUps.any(
        (p) =>
            (p.type == PowerUpType.speedBoost ||
                p.type == PowerUpType.slowMotion) &&
            p.isActive,
      ),
      hasScoreModifier: activePowerUps.any(
        (p) => p.type == PowerUpType.doublePoints && p.isActive,
      ),
      hasProtection: activePowerUps.any(
        (p) =>
            (p.type == PowerUpType.shield || p.type == PowerUpType.ghostMode) &&
            p.isActive,
      ),
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Power-up statistics
class PowerUpStatistics {
  final int powerUpsOnGrid;
  final int activePowerUps;
  final List<PowerUpType> activeTypes;
  final bool hasSpeedModifier;
  final bool hasScoreModifier;
  final bool hasProtection;

  const PowerUpStatistics({
    required this.powerUpsOnGrid,
    required this.activePowerUps,
    required this.activeTypes,
    required this.hasSpeedModifier,
    required this.hasScoreModifier,
    required this.hasProtection,
  });
}
