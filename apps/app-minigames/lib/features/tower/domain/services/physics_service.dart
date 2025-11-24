import '../entities/enums.dart';

/// Model representing physics update result
class PhysicsUpdateResult {
  /// The new X position after movement
  final double newPosX;

  /// The new movement direction (true = right, false = left)
  final bool newMovingRight;

  /// Whether the block hit a boundary and reversed direction
  final bool didReverse;

  const PhysicsUpdateResult({
    required this.newPosX,
    required this.newMovingRight,
    required this.didReverse,
  });
}

/// Model representing speed calculation result
class SpeedCalculationResult {
  /// The new block speed after adjustment
  final double newSpeed;

  /// The speed increment that was applied
  final double increment;

  /// The current speed tier (for display)
  final String speedTier;

  const SpeedCalculationResult({
    required this.newSpeed,
    required this.increment,
    required this.speedTier,
  });
}

/// Service responsible for physics calculations and movement logic
///
/// This service handles all physics-related operations:
/// - Block movement and position updates
/// - Boundary detection and collision
/// - Direction control and reversal
/// - Speed progression and calculation
class PhysicsService {
  /// Base speed increment per drop
  static const double baseSpeedIncrement = 0.2;

  /// Maximum speed cap to prevent unplayable situations
  static const double maxSpeed = 30.0;

  /// Minimum speed to ensure the game remains playable
  static const double minSpeed = 1.0;

  /// Updates the block position based on current movement
  ///
  /// The block moves horizontally at the given speed. When it reaches
  /// the screen boundaries, it reverses direction.
  ///
  /// [currentPosX] Current X position of the block
  /// [blockWidth] Width of the moving block
  /// [blockSpeed] Speed of movement
  /// [movingRight] Current direction (true = right, false = left)
  /// [screenWidth] Width of the game screen
  ///
  /// Returns a [PhysicsUpdateResult] with new position and direction
  PhysicsUpdateResult updatePosition({
    required double currentPosX,
    required double blockWidth,
    required double blockSpeed,
    required bool movingRight,
    required double screenWidth,
  }) {
    // Calculate new position based on direction
    double newPosX =
        movingRight ? currentPosX + blockSpeed : currentPosX - blockSpeed;

    bool newMovingRight = movingRight;
    bool didReverse = false;

    // Check right boundary
    if (newPosX + blockWidth >= screenWidth) {
      newPosX = screenWidth - blockWidth;
      newMovingRight = false;
      didReverse = true;
    }
    // Check left boundary
    else if (newPosX <= 0) {
      newPosX = 0;
      newMovingRight = true;
      didReverse = true;
    }

    return PhysicsUpdateResult(
      newPosX: newPosX,
      newMovingRight: newMovingRight,
      didReverse: didReverse,
    );
  }

  /// Checks if a position is within screen boundaries
  ///
  /// [posX] The X position to check
  /// [blockWidth] Width of the block
  /// [screenWidth] Width of the game screen
  ///
  /// Returns true if the position is valid (within boundaries)
  bool isWithinBoundaries({
    required double posX,
    required double blockWidth,
    required double screenWidth,
  }) {
    return posX >= 0 && posX + blockWidth <= screenWidth;
  }

  /// Checks if a block is touching the right boundary
  ///
  /// [posX] The X position of the block
  /// [blockWidth] Width of the block
  /// [screenWidth] Width of the game screen
  ///
  /// Returns true if touching or exceeding the right edge
  bool isTouchingRightBoundary({
    required double posX,
    required double blockWidth,
    required double screenWidth,
  }) {
    return posX + blockWidth >= screenWidth;
  }

  /// Checks if a block is touching the left boundary
  ///
  /// [posX] The X position of the block
  ///
  /// Returns true if touching or exceeding the left edge
  bool isTouchingLeftBoundary(double posX) {
    return posX <= 0;
  }

  /// Calculates the new speed after a block drop
  ///
  /// Speed increases progressively with each successful drop,
  /// making the game harder. The increase is scaled by difficulty.
  ///
  /// [currentSpeed] The current block speed
  /// [difficulty] The game difficulty setting
  ///
  /// Returns a [SpeedCalculationResult] with new speed and metadata
  SpeedCalculationResult calculateSpeedIncrease({
    required double currentSpeed,
    required GameDifficulty difficulty,
  }) {
    // Calculate increment based on difficulty
    final increment = baseSpeedIncrement * difficulty.speedMultiplier;

    // Apply increment but cap at maximum
    final newSpeed = (currentSpeed + increment).clamp(minSpeed, maxSpeed);

    // Determine speed tier for display/feedback
    final speedTier = _getSpeedTier(newSpeed);

    return SpeedCalculationResult(
      newSpeed: newSpeed,
      increment: increment,
      speedTier: speedTier,
    );
  }

  /// Calculates the speed adjustment when changing difficulty
  ///
  /// When difficulty changes mid-game, we need to recalculate speed
  /// to maintain the same progression ratio.
  ///
  /// [currentSpeed] The current block speed
  /// [currentDifficulty] The current difficulty setting
  /// [newDifficulty] The new difficulty setting
  /// [baseSpeed] The base speed (typically 5.0)
  ///
  /// Returns the adjusted speed for the new difficulty
  double calculateDifficultySpeedAdjustment({
    required double currentSpeed,
    required GameDifficulty currentDifficulty,
    required GameDifficulty newDifficulty,
    double baseSpeed = 5.0,
  }) {
    // Calculate current speed ratio (how much faster than base)
    final currentSpeedRatio =
        currentSpeed / (baseSpeed * currentDifficulty.speedMultiplier);

    // Apply same ratio to new difficulty
    final newSpeed =
        baseSpeed * newDifficulty.speedMultiplier * currentSpeedRatio;

    return newSpeed.clamp(minSpeed, maxSpeed);
  }

  /// Determines the speed tier based on current speed
  ///
  /// [speed] The current speed value
  ///
  /// Returns a tier string: 'Insano', 'Muito Rápido', 'Rápido', 'Moderado', or 'Lento'
  String _getSpeedTier(double speed) {
    if (speed >= 20.0) {
      return 'Insano';
    } else if (speed >= 15.0) {
      return 'Muito Rápido';
    } else if (speed >= 10.0) {
      return 'Rápido';
    } else if (speed >= 5.0) {
      return 'Moderado';
    } else {
      return 'Lento';
    }
  }

  /// Gets the public speed tier (exposed for external use)
  ///
  /// [speed] The current speed value
  ///
  /// Returns the speed tier string
  String getSpeedTier(double speed) {
    return _getSpeedTier(speed);
  }

  /// Calculates the distance traveled per frame
  ///
  /// [speed] The movement speed
  /// [deltaTime] Time elapsed since last frame (in seconds)
  ///
  /// Returns the distance traveled
  double calculateDistancePerFrame({
    required double speed,
    double deltaTime = 1.0,
  }) {
    return speed * deltaTime;
  }

  /// Calculates the time to cross the screen
  ///
  /// [speed] The current speed
  /// [screenWidth] Width of the screen
  /// [blockWidth] Width of the block
  ///
  /// Returns the time in seconds to cross from left to right
  double calculateCrossingTime({
    required double speed,
    required double screenWidth,
    required double blockWidth,
  }) {
    final distanceToCover = screenWidth - blockWidth;
    if (speed == 0) return double.infinity;
    return distanceToCover / speed;
  }

  /// Validates if a speed value is within acceptable bounds
  ///
  /// [speed] The speed to validate
  ///
  /// Returns true if speed is within min and max bounds
  bool isValidSpeed(double speed) {
    return speed >= minSpeed && speed <= maxSpeed;
  }

  /// Resets speed to initial value for a difficulty
  ///
  /// [difficulty] The difficulty setting
  /// [baseSpeed] The base speed (typically 5.0)
  ///
  /// Returns the initial speed for the given difficulty
  double getInitialSpeed({
    required GameDifficulty difficulty,
    double baseSpeed = 5.0,
  }) {
    return baseSpeed * difficulty.speedMultiplier;
  }

  /// Calculates the reversal position when hitting a boundary
  ///
  /// When a block exceeds a boundary, this clamps it back to valid range.
  ///
  /// [posX] The current position
  /// [blockWidth] Width of the block
  /// [screenWidth] Width of the screen
  ///
  /// Returns the clamped position within boundaries
  double clampPosition({
    required double posX,
    required double blockWidth,
    required double screenWidth,
  }) {
    if (posX < 0) {
      return 0;
    } else if (posX + blockWidth > screenWidth) {
      return screenWidth - blockWidth;
    }
    return posX;
  }
}
