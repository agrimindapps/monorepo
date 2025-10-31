// Package imports:
import 'package:equatable/equatable.dart';
import 'dart:math';

/// Entity representing the bird in the Flappy Bird game
class BirdEntity extends Equatable {
  /// Vertical position (pixels from top)
  final double y;

  /// Vertical velocity (pixels per frame)
  final double velocity;

  /// Bird rotation angle (radians, -π/2 to π/4)
  final double rotation;

  /// Bird size (width and height in pixels)
  final double size;

  const BirdEntity({
    required this.y,
    this.velocity = 0.0,
    this.rotation = 0.0,
    this.size = 50.0,
  });

  /// Initial bird state (centered vertically)
  factory BirdEntity.initial({
    required double screenHeight,
    double size = 50.0,
  }) {
    return BirdEntity(
      y: screenHeight * 0.5, // Center of screen
      velocity: 0.0,
      rotation: 0.0,
      size: size,
    );
  }

  /// @deprecated Use PhysicsService.applyGravity() instead
  /// This method is kept for backward compatibility but should not be used
  @Deprecated('Use PhysicsService.applyGravity instead')
  BirdEntity applyGravity(double gravity) {
    final newVelocity = velocity + gravity;
    final newY = y + newVelocity;

    // Update rotation based on velocity (falling = rotate down, jumping = rotate up)
    final newRotation = min(pi / 4, max(-pi / 2, newVelocity * 0.04));

    return copyWith(
      velocity: newVelocity,
      y: newY,
      rotation: newRotation,
    );
  }

  /// @deprecated Use PhysicsService.applyJump() instead
  /// This method is kept for backward compatibility but should not be used
  @Deprecated('Use PhysicsService.applyJump instead')
  BirdEntity flap(double jumpStrength) {
    return copyWith(
      velocity: jumpStrength,
      rotation: -0.4, // Tilt upward when jumping
    );
  }

  /// Check if bird is colliding with ground
  /// @deprecated Use CollisionService.checkGroundCollision() instead
  /// Note: This method used size/2 which was inconsistent with CollisionService
  @Deprecated('Use CollisionService.checkGroundCollision instead')
  bool isCollidingWithGround(double groundY) {
    return y + size >= groundY;
  }

  /// Check if bird is colliding with ceiling
  /// @deprecated Use CollisionService.checkCeilingCollision() instead
  @Deprecated('Use CollisionService.checkCeilingCollision instead')
  bool isCollidingWithCeiling() {
    return y <= 0;
  }

  /// Check collision with screen boundaries
  bool isOutOfBounds(double groundY) {
    return isCollidingWithGround(groundY) || isCollidingWithCeiling();
  }

  /// Create a copy with modified fields
  BirdEntity copyWith({
    double? y,
    double? velocity,
    double? rotation,
    double? size,
  }) {
    return BirdEntity(
      y: y ?? this.y,
      velocity: velocity ?? this.velocity,
      rotation: rotation ?? this.rotation,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [y, velocity, rotation, size];
}
