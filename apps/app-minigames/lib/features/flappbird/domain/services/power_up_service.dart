import 'dart:math';
import '../entities/power_up_entity.dart';
import '../entities/enums.dart';

/// Service for power-up generation and management
class PowerUpService {
  final Random _random = Random();

  /// Probability of spawning a power-up (0.0 to 1.0)
  static const double spawnProbability = 0.15; // 15% chance per pipe

  /// Minimum pipes between power-ups
  static const int minPipesBetweenPowerUps = 3;

  /// Generate a random power-up type based on spawn weights
  PowerUpType generateRandomType() {
    final totalWeight = PowerUpType.values.fold<int>(
      0,
      (sum, type) => sum + type.spawnWeight,
    );

    var randomValue = _random.nextInt(totalWeight);

    for (final type in PowerUpType.values) {
      randomValue -= type.spawnWeight;
      if (randomValue < 0) {
        return type;
      }
    }

    return PowerUpType.shield; // Fallback
  }

  /// Check if a power-up should spawn
  bool shouldSpawnPowerUp(int pipesSinceLastPowerUp) {
    if (pipesSinceLastPowerUp < minPipesBetweenPowerUps) {
      return false;
    }
    return _random.nextDouble() < spawnProbability;
  }

  /// Create a new power-up entity
  PowerUpEntity createPowerUp({
    required double x,
    required double screenHeight,
    required double groundHeight,
    PowerUpType? type,
  }) {
    final powerUpType = type ?? generateRandomType();

    // Random Y position within playable area (with padding)
    final minY = screenHeight * 0.2;
    final maxY = screenHeight - groundHeight - screenHeight * 0.2;
    final y = minY + _random.nextDouble() * (maxY - minY);

    return PowerUpEntity(
      id: 'powerup_${DateTime.now().millisecondsSinceEpoch}',
      type: powerUpType,
      x: x,
      y: y,
    );
  }

  /// Activate a power-up and return the active power-up entity
  ActivePowerUp activatePowerUp(PowerUpType type) {
    if (type.isUseBased) {
      return ActivePowerUp.useBased(
        type: type,
        uses: type.durationSeconds, // For use-based, durationSeconds = uses
      );
    } else {
      return ActivePowerUp.timed(
        type: type,
        duration: type.duration,
      );
    }
  }

  /// Check if any active power-up provides shield protection
  bool hasShieldProtection(List<ActivePowerUp> activePowerUps) {
    return activePowerUps.any(
      (p) => p.type == PowerUpType.shield && !p.isExpired,
    );
  }

  /// Check if any active power-up provides ghost ability
  bool hasGhostAbility(List<ActivePowerUp> activePowerUps) {
    return activePowerUps.any(
      (p) => p.type == PowerUpType.ghost && !p.isExpired,
    );
  }

  /// Get current speed multiplier from active power-ups
  double getSpeedMultiplier(List<ActivePowerUp> activePowerUps) {
    for (final powerUp in activePowerUps) {
      if (!powerUp.isExpired && powerUp.type == PowerUpType.slowMotion) {
        return powerUp.type.speedMultiplier;
      }
    }
    return 1.0;
  }

  /// Get current size multiplier from active power-ups
  double getSizeMultiplier(List<ActivePowerUp> activePowerUps) {
    for (final powerUp in activePowerUps) {
      if (!powerUp.isExpired && powerUp.type == PowerUpType.shrink) {
        return powerUp.type.sizeMultiplier;
      }
    }
    return 1.0;
  }

  /// Get current points multiplier from active power-ups
  int getPointsMultiplier(List<ActivePowerUp> activePowerUps) {
    for (final powerUp in activePowerUps) {
      if (!powerUp.isExpired && powerUp.type == PowerUpType.doublePoints) {
        return powerUp.type.pointsMultiplier;
      }
    }
    return 1;
  }

  /// Check if magnet is active
  bool hasMagnetActive(List<ActivePowerUp> activePowerUps) {
    return activePowerUps.any(
      (p) => p.type == PowerUpType.magnet && !p.isExpired,
    );
  }

  /// Consume shield on collision (returns updated list)
  List<ActivePowerUp> consumeShield(List<ActivePowerUp> activePowerUps) {
    final updatedPowerUps = <ActivePowerUp>[];

    for (final powerUp in activePowerUps) {
      if (powerUp.type == PowerUpType.shield && !powerUp.isExpired) {
        final consumed = powerUp.consumeUse();
        if (!consumed.isExpired) {
          updatedPowerUps.add(consumed);
        }
        // Don't add if expired
      } else {
        updatedPowerUps.add(powerUp);
      }
    }

    return updatedPowerUps;
  }

  /// Consume ghost on pipe pass (returns updated list)
  List<ActivePowerUp> consumeGhost(List<ActivePowerUp> activePowerUps) {
    final updatedPowerUps = <ActivePowerUp>[];

    for (final powerUp in activePowerUps) {
      if (powerUp.type == PowerUpType.ghost && !powerUp.isExpired) {
        final consumed = powerUp.consumeUse();
        if (!consumed.isExpired) {
          updatedPowerUps.add(consumed);
        }
      } else {
        updatedPowerUps.add(powerUp);
      }
    }

    return updatedPowerUps;
  }

  /// Remove expired power-ups
  List<ActivePowerUp> removeExpired(List<ActivePowerUp> activePowerUps) {
    return activePowerUps.where((p) => !p.isExpired).toList();
  }

  /// Apply magnet effect to power-ups (attract toward bird)
  List<PowerUpEntity> applyMagnetEffect({
    required List<PowerUpEntity> powerUps,
    required double birdX,
    required double birdY,
    required double magnetStrength,
  }) {
    return powerUps.map((powerUp) {
      if (powerUp.collected) return powerUp;

      // Calculate direction toward bird
      final dx = birdX - powerUp.x;
      final dy = birdY - powerUp.y;
      final distance = (dx * dx + dy * dy);

      if (distance < 1) return powerUp;

      // Normalize and apply magnetic force
      final dist = distance;
      final force = magnetStrength / dist.clamp(50, 500);

      return powerUp.copyWith(
        x: powerUp.x + dx * force,
        y: powerUp.y + dy * force,
      );
    }).toList();
  }
}
