// Package imports:
import 'package:equatable/equatable.dart';

// Domain imports:
import 'enums.dart';
import 'position.dart';

/// Entity representing a power-up item on the game grid
class PowerUp extends Equatable {
  final String id;
  final PowerUpType type;
  final Position position;
  final DateTime spawnedAt;
  final Duration lifetime;

  const PowerUp({
    required this.id,
    required this.type,
    required this.position,
    required this.spawnedAt,
    this.lifetime = const Duration(seconds: 10),
  });

  /// Check if this power-up has expired on the grid
  bool get isExpired => DateTime.now().difference(spawnedAt) > lifetime;

  /// Remaining time before expiration
  Duration get remainingLifetime {
    final elapsed = DateTime.now().difference(spawnedAt);
    final remaining = lifetime - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Remaining lifetime as percentage (1.0 = full, 0.0 = expired)
  double get remainingLifetimePercent {
    final elapsed = DateTime.now().difference(spawnedAt).inMilliseconds;
    final total = lifetime.inMilliseconds;
    return (1 - (elapsed / total)).clamp(0.0, 1.0);
  }

  PowerUp copyWith({
    String? id,
    PowerUpType? type,
    Position? position,
    DateTime? spawnedAt,
    Duration? lifetime,
  }) {
    return PowerUp(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      spawnedAt: spawnedAt ?? this.spawnedAt,
      lifetime: lifetime ?? this.lifetime,
    );
  }

  @override
  List<Object?> get props => [id, type, position, spawnedAt, lifetime];
}

/// Entity representing an active power-up effect on the snake
class ActivePowerUp extends Equatable {
  final PowerUpType type;
  final DateTime activatedAt;
  final Duration duration;

  const ActivePowerUp({
    required this.type,
    required this.activatedAt,
    required this.duration,
  });

  /// Factory to create from PowerUpType with default duration
  factory ActivePowerUp.fromType(PowerUpType type) {
    return ActivePowerUp(
      type: type,
      activatedAt: DateTime.now(),
      duration: type.duration,
    );
  }

  /// Check if this power-up effect is still active
  bool get isActive => DateTime.now().difference(activatedAt) < duration;

  /// Remaining time of this power-up effect
  Duration get remainingDuration {
    final elapsed = DateTime.now().difference(activatedAt);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Remaining effect as percentage (1.0 = full, 0.0 = expired)
  double get remainingPercent {
    final elapsed = DateTime.now().difference(activatedAt).inMilliseconds;
    final total = duration.inMilliseconds;
    return (1 - (elapsed / total)).clamp(0.0, 1.0);
  }

  ActivePowerUp copyWith({
    PowerUpType? type,
    DateTime? activatedAt,
    Duration? duration,
  }) {
    return ActivePowerUp(
      type: type ?? this.type,
      activatedAt: activatedAt ?? this.activatedAt,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [type, activatedAt, duration];
}
