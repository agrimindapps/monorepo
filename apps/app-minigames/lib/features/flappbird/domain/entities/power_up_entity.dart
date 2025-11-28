import 'package:equatable/equatable.dart';
import 'enums.dart';

/// Entity representing a power-up that can be collected
class PowerUpEntity extends Equatable {
  final String id;
  final PowerUpType type;
  final double x;
  final double y;
  final bool collected;
  final double size;

  const PowerUpEntity({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.collected = false,
    this.size = 40.0,
  });

  /// Move power-up to the left
  PowerUpEntity moveLeft(double speed) {
    return copyWith(x: x - speed);
  }

  /// Check if power-up is off-screen
  bool isOffScreen() {
    return x + size < 0;
  }

  /// Mark as collected
  PowerUpEntity markCollected() {
    return copyWith(collected: true);
  }

  /// Check collision with bird
  bool checkCollision(double birdX, double birdY, double birdSize) {
    if (collected) return false;
    
    final birdRadius = birdSize / 2;
    final powerUpRadius = size / 2;
    
    final dx = (birdX) - (x + powerUpRadius);
    final dy = (birdY) - (y + powerUpRadius);
    final distance = (dx * dx + dy * dy);
    
    return distance <= (birdRadius + powerUpRadius) * (birdRadius + powerUpRadius);
  }

  PowerUpEntity copyWith({
    String? id,
    PowerUpType? type,
    double? x,
    double? y,
    bool? collected,
    double? size,
  }) {
    return PowerUpEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      collected: collected ?? this.collected,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [id, type, x, y, collected, size];
}

/// Entity representing an active power-up effect
class ActivePowerUp extends Equatable {
  final PowerUpType type;
  final DateTime activatedAt;
  final Duration? duration; // null = permanent until used
  final int? usesRemaining; // null = time-based, not use-based

  const ActivePowerUp({
    required this.type,
    required this.activatedAt,
    this.duration,
    this.usesRemaining,
  });

  /// Create a time-based power-up
  factory ActivePowerUp.timed({
    required PowerUpType type,
    required Duration duration,
  }) {
    return ActivePowerUp(
      type: type,
      activatedAt: DateTime.now(),
      duration: duration,
    );
  }

  /// Create a use-based power-up (like shield with 1 use)
  factory ActivePowerUp.useBased({
    required PowerUpType type,
    required int uses,
  }) {
    return ActivePowerUp(
      type: type,
      activatedAt: DateTime.now(),
      usesRemaining: uses,
    );
  }

  /// Check if power-up is expired
  bool get isExpired {
    if (usesRemaining != null) {
      return usesRemaining! <= 0;
    }
    if (duration != null) {
      return DateTime.now().difference(activatedAt) >= duration!;
    }
    return false;
  }

  /// Remaining time in seconds
  double get remainingSeconds {
    if (duration == null) return double.infinity;
    final elapsed = DateTime.now().difference(activatedAt);
    final remaining = duration! - elapsed;
    return remaining.inMilliseconds / 1000.0;
  }

  /// Progress percentage (0.0 to 1.0, where 1.0 = full, 0.0 = expired)
  double get remainingPercent {
    if (duration == null) return 1.0;
    final elapsed = DateTime.now().difference(activatedAt);
    final progress = 1.0 - (elapsed.inMilliseconds / duration!.inMilliseconds);
    return progress.clamp(0.0, 1.0);
  }

  /// Consume one use (for use-based power-ups)
  ActivePowerUp consumeUse() {
    if (usesRemaining == null || usesRemaining! <= 0) return this;
    return ActivePowerUp(
      type: type,
      activatedAt: activatedAt,
      duration: duration,
      usesRemaining: usesRemaining! - 1,
    );
  }

  @override
  List<Object?> get props => [type, activatedAt, duration, usesRemaining];
}
