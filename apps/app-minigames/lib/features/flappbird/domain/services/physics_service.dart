import 'package:injectable/injectable.dart';

import '../entities/bird_entity.dart';

/// Service responsible for bird physics calculations
/// Follows SRP by handling only physics operations
@lazySingleton
class PhysicsService {
  /// Gravity constant (pixels per frame at 60fps)
  static const double defaultGravity = 0.6;

  /// Jump strength (negative velocity = upward)
  static const double defaultJumpStrength = -10.0;

  /// Terminal velocity (max falling speed)
  static const double terminalVelocity = 12.0;

  /// Maximum upward velocity
  static const double maxUpwardVelocity = -12.0;

  /// Applies gravity to bird velocity and position
  BirdEntity applyGravity({
    required BirdEntity bird,
    double gravity = defaultGravity,
  }) {
    final newVelocity = _clampVelocity(bird.velocity + gravity);
    final newY = bird.y + newVelocity;

    return bird.copyWith(
      velocity: newVelocity,
      y: newY,
    );
  }

  /// Applies jump (flap) to bird
  BirdEntity applyJump({
    required BirdEntity bird,
    double jumpStrength = defaultJumpStrength,
  }) {
    return bird.copyWith(velocity: jumpStrength);
  }

  /// Clamps velocity to prevent extreme speeds
  double _clampVelocity(double velocity) {
    if (velocity > terminalVelocity) return terminalVelocity;
    if (velocity < maxUpwardVelocity) return maxUpwardVelocity;
    return velocity;
  }

  /// Checks if bird is out of bounds
  bool isBirdOutOfBounds({
    required BirdEntity bird,
    required double playAreaHeight,
  }) {
    return bird.y < 0 || bird.y > playAreaHeight - bird.size;
  }

  /// Gets bird rotation based on velocity (for visual effect)
  double getBirdRotation(BirdEntity bird) {
    // Rotate based on velocity (-45° to +90°)
    final rotation = bird.velocity * 0.05;
    return rotation.clamp(-0.785, 1.571); // -45° to 90° in radians
  }

  /// Calculates falling distance in next frame
  double predictFallDistance({
    required double currentVelocity,
    double gravity = defaultGravity,
  }) {
    return currentVelocity + gravity;
  }

  /// Calculates number of frames until bird hits ground
  int framesUntilGround({
    required BirdEntity bird,
    required double playAreaHeight,
    double gravity = defaultGravity,
  }) {
    if (bird.velocity < 0) {
      // Bird is moving up, calculate time to peak then fall
      final framesToPeak = bird.velocity.abs() / gravity;
      final distanceToGround = playAreaHeight - bird.size - bird.y;
      final framesToFall = _calculateFallFrames(distanceToGround, gravity);
      return (framesToPeak + framesToFall).ceil();
    } else {
      // Bird is falling
      final distanceToGround = playAreaHeight - bird.size - bird.y;
      return _calculateFallFrames(distanceToGround, gravity).ceil();
    }
  }

  /// Calculates frames to fall a given distance
  double _calculateFallFrames(double distance, double gravity) {
    // Using physics: d = 0.5 * g * t^2, solve for t
    // Simplified for frame-by-frame: sum of velocities
    double totalDistance = 0;
    double velocity = 0;
    int frames = 0;

    while (totalDistance < distance && frames < 1000) {
      velocity += gravity;
      velocity = _clampVelocity(velocity);
      totalDistance += velocity;
      frames++;
    }

    return frames.toDouble();
  }

  /// Gets physics statistics
  PhysicsStatistics getStatistics({
    required BirdEntity bird,
    required double playAreaHeight,
  }) {
    return PhysicsStatistics(
      velocity: bird.velocity,
      isFalling: bird.velocity > 0,
      isRising: bird.velocity < 0,
      distanceToGround: playAreaHeight - bird.size - bird.y,
      distanceToCeiling: bird.y,
      rotation: getBirdRotation(bird),
      framesUntilGround: framesUntilGround(
        bird: bird,
        playAreaHeight: playAreaHeight,
      ),
    );
  }

  /// Validates physics parameters
  PhysicsValidation validatePhysics({
    required double gravity,
    required double jumpStrength,
  }) {
    if (gravity <= 0) {
      return PhysicsValidation(
        isValid: false,
        errorMessage: 'Gravity must be positive',
      );
    }

    if (jumpStrength >= 0) {
      return PhysicsValidation(
        isValid: false,
        errorMessage: 'Jump strength must be negative (upward)',
      );
    }

    if (jumpStrength.abs() < gravity) {
      return PhysicsValidation(
        isValid: false,
        errorMessage: 'Jump strength too weak for gravity',
      );
    }

    return PhysicsValidation(isValid: true);
  }
}

// Models

class PhysicsStatistics {
  final double velocity;
  final bool isFalling;
  final bool isRising;
  final double distanceToGround;
  final double distanceToCeiling;
  final double rotation;
  final int framesUntilGround;

  PhysicsStatistics({
    required this.velocity,
    required this.isFalling,
    required this.isRising,
    required this.distanceToGround,
    required this.distanceToCeiling,
    required this.rotation,
    required this.framesUntilGround,
  });
}

class PhysicsValidation {
  final bool isValid;
  final String? errorMessage;

  PhysicsValidation({
    required this.isValid,
    this.errorMessage,
  });
}
