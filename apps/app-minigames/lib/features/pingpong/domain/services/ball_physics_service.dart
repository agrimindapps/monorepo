import 'dart:math';

import 'package:injectable/injectable.dart';

import '../entities/ball_entity.dart';

/// Service responsible for ball physics and movement
///
/// Handles:
/// - Ball movement calculations
/// - Velocity management
/// - Bounce physics
/// - Speed capping
/// - Angle adjustments
@lazySingleton
class BallPhysicsService {
  final Random _random;

  BallPhysicsService({Random? random}) : _random = random ?? Random();

  // ============================================================================
  // Constants
  // ============================================================================

  /// Initial horizontal speed when ball spawns
  static const double initialVelocityX = 0.005;

  /// Maximum random vertical velocity at spawn
  static const double maxInitialVelocityY = 0.004;

  /// Maximum angle deviation from horizontal
  static const double maxAngle = 0.008;

  /// Speed increase multiplier on paddle hit
  static const double speedIncreaseMultiplier = 1.05;

  /// Maximum ball speed (speed cap)
  static const double maxSpeed = 0.015;

  /// Ball radius in pixels
  static const double defaultRadius = 10.0;

  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Moves ball based on current velocity
  BallEntity moveBall(BallEntity ball) {
    return ball.copyWith(
      x: ball.x + ball.velocityX,
      y: ball.y + ball.velocityY,
    );
  }

  /// Bounces ball vertically (inverts Y velocity)
  BallEntity bounceVertical(BallEntity ball) {
    return ball.copyWith(velocityY: -ball.velocityY);
  }

  /// Bounces ball horizontally with speed increase
  BallEntity bounceHorizontal(
    BallEntity ball, {
    double speedIncrease = speedIncreaseMultiplier,
  }) {
    return ball.copyWith(
      velocityX: -ball.velocityX * speedIncrease,
      velocityY: ball.velocityY * speedIncrease,
    );
  }

  /// Sets ball angle based on hit position on paddle
  ///
  /// [hitPosition] ranges from -1.0 (top) to 1.0 (bottom)
  BallEntity setAngle(BallEntity ball, double hitPosition) {
    final newVelocityY = hitPosition * maxAngle;
    return ball.copyWith(velocityY: newVelocityY);
  }

  /// Caps ball speed to maximum allowed speed
  BallEntity capSpeed(BallEntity ball, {double? customMaxSpeed}) {
    final speedLimit = customMaxSpeed ?? maxSpeed;
    final currentSpeed = calculateSpeed(ball);

    if (currentSpeed <= speedLimit) {
      return ball;
    }

    final ratio = speedLimit / currentSpeed;
    return ball.copyWith(
      velocityX: ball.velocityX * ratio,
      velocityY: ball.velocityY * ratio,
    );
  }

  // ============================================================================
  // Ball Creation
  // ============================================================================

  /// Creates initial ball with random direction
  BallEntity createInitialBall() {
    return BallEntity(
      x: 0.5,
      y: 0.5,
      velocityX: _random.nextBool() ? initialVelocityX : -initialVelocityX,
      velocityY: generateRandomVerticalVelocity(),
      radius: defaultRadius,
    );
  }

  /// Resets ball to center with specified direction
  BallEntity resetBall({required bool toLeft}) {
    return BallEntity(
      x: 0.5,
      y: 0.5,
      velocityX: toLeft ? -initialVelocityX : initialVelocityX,
      velocityY: generateRandomVerticalVelocity(),
      radius: defaultRadius,
    );
  }

  /// Generates random vertical velocity for ball spawn
  double generateRandomVerticalVelocity() {
    return (_random.nextDouble() * maxInitialVelocityY) -
        (maxInitialVelocityY / 2);
  }

  // ============================================================================
  // Physics Calculations
  // ============================================================================

  /// Calculates current ball speed (magnitude of velocity vector)
  double calculateSpeed(BallEntity ball) {
    return sqrt(
      ball.velocityX * ball.velocityX + ball.velocityY * ball.velocityY,
    );
  }

  /// Calculates ball direction angle in radians
  double calculateAngle(BallEntity ball) {
    return atan2(ball.velocityY, ball.velocityX);
  }

  /// Checks if ball is moving left
  bool isMovingLeft(BallEntity ball) => ball.velocityX < 0;

  /// Checks if ball is moving right
  bool isMovingRight(BallEntity ball) => ball.velocityX > 0;

  /// Checks if ball is moving up
  bool isMovingUp(BallEntity ball) => ball.velocityY < 0;

  /// Checks if ball is moving down
  bool isMovingDown(BallEntity ball) => ball.velocityY > 0;

  // ============================================================================
  // Boundary Checking
  // ============================================================================

  /// Checks if ball hit top boundary
  bool hitTopBoundary(BallEntity ball, {double topBound = 0.0}) {
    return ball.y <= topBound;
  }

  /// Checks if ball hit bottom boundary
  bool hitBottomBoundary(BallEntity ball, {double bottomBound = 1.0}) {
    return ball.y >= bottomBound;
  }

  /// Checks if ball hit left boundary (player missed)
  bool hitLeftBoundary(BallEntity ball, {double leftBound = 0.0}) {
    return ball.x <= leftBound;
  }

  /// Checks if ball hit right boundary (AI missed)
  bool hitRightBoundary(BallEntity ball, {double rightBound = 1.0}) {
    return ball.x >= rightBound;
  }

  /// Checks if ball needs vertical bounce
  bool needsVerticalBounce(
    BallEntity ball, {
    double topBound = 0.0,
    double bottomBound = 1.0,
  }) {
    return hitTopBoundary(ball, topBound: topBound) ||
        hitBottomBoundary(ball, bottomBound: bottomBound);
  }

  // ============================================================================
  // Prediction Methods
  // ============================================================================

  /// Predicts ball position after N frames
  BallEntity predictPosition(BallEntity ball, int frames) {
    var predicted = ball;
    for (int i = 0; i < frames; i++) {
      predicted = moveBall(predicted);
    }
    return predicted;
  }

  /// Estimates time until ball reaches specific X position
  int estimateFramesToX(BallEntity ball, double targetX) {
    if (ball.velocityX == 0) return -1; // Never reaches

    final distance = (targetX - ball.x).abs();
    final framesNeeded = (distance / ball.velocityX.abs()).ceil();

    return framesNeeded;
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets ball physics statistics
  BallStatistics getStatistics(BallEntity ball) {
    final speed = calculateSpeed(ball);
    final angle = calculateAngle(ball);
    final speedPercentage = (speed / maxSpeed * 100).clamp(0.0, 100.0);

    return BallStatistics(
      speed: speed,
      angle: angle,
      speedPercentage: speedPercentage,
      isAtMaxSpeed: speed >= maxSpeed,
      horizontalSpeed: ball.velocityX.abs(),
      verticalSpeed: ball.velocityY.abs(),
      movingLeft: isMovingLeft(ball),
      movingRight: isMovingRight(ball),
      movingUp: isMovingUp(ball),
      movingDown: isMovingDown(ball),
    );
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates ball physics state
  PhysicsValidation validatePhysics(BallEntity ball) {
    final errors = <String>[];
    final speed = calculateSpeed(ball);

    if (speed > maxSpeed * 1.1) {
      errors.add('Speed exceeds safe limit: $speed (max: $maxSpeed)');
    }

    if (ball.x < -0.1 || ball.x > 1.1) {
      errors.add('Ball X out of reasonable bounds: ${ball.x}');
    }

    if (ball.y < -0.1 || ball.y > 1.1) {
      errors.add('Ball Y out of reasonable bounds: ${ball.y}');
    }

    if (speed == 0) {
      errors.add('Ball has zero velocity');
    }

    return PhysicsValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // Testing Utilities
  // ============================================================================

  /// Creates ball with specific configuration for testing
  BallEntity createTestBall({
    double x = 0.5,
    double y = 0.5,
    double? velocityX,
    double? velocityY,
    double radius = defaultRadius,
  }) {
    return BallEntity(
      x: x,
      y: y,
      velocityX: velocityX ?? initialVelocityX,
      velocityY: velocityY ?? 0.0,
      radius: radius,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Statistics about ball physics
class BallStatistics {
  final double speed;
  final double angle;
  final double speedPercentage;
  final bool isAtMaxSpeed;
  final double horizontalSpeed;
  final double verticalSpeed;
  final bool movingLeft;
  final bool movingRight;
  final bool movingUp;
  final bool movingDown;

  const BallStatistics({
    required this.speed,
    required this.angle,
    required this.speedPercentage,
    required this.isAtMaxSpeed,
    required this.horizontalSpeed,
    required this.verticalSpeed,
    required this.movingLeft,
    required this.movingRight,
    required this.movingUp,
    required this.movingDown,
  });

  /// Gets direction as string
  String get directionString {
    final horizontal = movingLeft ? 'Left' : 'Right';
    final vertical = movingUp
        ? 'Up'
        : movingDown
            ? 'Down'
            : 'Straight';
    return '$horizontal-$vertical';
  }
}

/// Validation result for ball physics
class PhysicsValidation {
  final bool isValid;
  final List<String> errors;

  const PhysicsValidation({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}
