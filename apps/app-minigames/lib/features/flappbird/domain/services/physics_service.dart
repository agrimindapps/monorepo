import 'package:injectable/injectable.dart';

import '../entities/bird_entity.dart';

/// Service responsible for bird physics calculations
/// Follows SRP by handling only physics operations
/// Supports delta time for frame-rate independent movement
@lazySingleton
class PhysicsService {
  /// Gravity constant (pixels per second²)
  /// Adjusted for display: ~960 pixels/s² = 0.6 pixels/frame at 60fps
  static const double defaultGravity = 960.0; // pixels per second²

  /// Jump strength (negative velocity = upward, pixels per second)
  /// ~600 pixels/s = -10 pixels/frame at 60fps
  static const double defaultJumpStrength = -600.0; // pixels per second

  /// Terminal velocity (max falling speed, pixels per second)
  /// ~720 pixels/s = 12 pixels/frame at 60fps
  static const double terminalVelocity = 720.0; // pixels per second

  /// Maximum upward velocity (pixels per second)
  /// ~720 pixels/s = -12 pixels/frame at 60fps
  static const double maxUpwardVelocity = -720.0; // pixels per second

  /// Default frame duration (1/60 second at 60fps)
  /// Used as fallback if deltaTime is not provided
  static const double defaultDeltaTime = 1.0 / 60.0;

  /// Applies gravity to bird velocity and position, with rotation update
  /// This is the unified method for applying physics to the bird
  /// Supports delta time for frame-rate independent movement
  ///
  /// [deltaTimeSeconds] - Time elapsed since last frame in seconds (default: 1/60s)
  /// [gravity] - Acceleration in pixels/second² (default: 960)
  BirdEntity applyGravity({
    required BirdEntity bird,
    double gravity = defaultGravity,
    double deltaTimeSeconds = defaultDeltaTime,
  }) {
    // Apply gravity with delta time: a = g * dt
    final gravityThisFrame = gravity * deltaTimeSeconds;
    final newVelocity = _clampVelocity(bird.velocity + gravityThisFrame);

    // Move bird based on velocity: d = v * dt
    final newY = bird.y + (newVelocity * deltaTimeSeconds);
    final newRotation = _calculateRotation(newVelocity);

    return bird.copyWith(
      velocity: newVelocity,
      y: newY,
      rotation: newRotation,
    );
  }

  /// Applies jump (flap) to bird with instant rotation update
  /// Velocity is set to jumpStrength and clamped to maxUpwardVelocity
  ///
  /// [deltaTimeSeconds] - Time elapsed since last frame in seconds (used for consistency)
  /// [jumpStrength] - Velocity change in pixels/second (default: -600)
  BirdEntity applyJump({
    required BirdEntity bird,
    double jumpStrength = defaultJumpStrength,
    double deltaTimeSeconds = defaultDeltaTime,
  }) {
    final clampedVelocity = _clampVelocity(jumpStrength);
    final newRotation = _calculateRotation(clampedVelocity);

    return bird.copyWith(
      velocity: clampedVelocity,
      rotation: newRotation,
    );
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
  /// @deprecated Use _calculateRotation() or let applyGravity/applyJump handle it
  double getBirdRotation(BirdEntity bird) {
    return _calculateRotation(bird.velocity);
  }

  /// Calculates bird rotation based on velocity
  /// Unified rotation calculation: -90° to +45° (radians: -π/2 to π/4)
  /// Sensitivity: 0.05 radians per pixel/frame velocity
  double _calculateRotation(double velocity) {
    final rotation = velocity * 0.05;
    return rotation.clamp(-1.5708, 0.7854); // -90° to 45° in radians
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
