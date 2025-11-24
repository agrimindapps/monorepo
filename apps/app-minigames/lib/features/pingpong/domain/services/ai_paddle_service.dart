
import '../entities/ball_entity.dart';
import '../entities/enums.dart';
import '../entities/paddle_entity.dart';

/// Service responsible for AI paddle movement and decision making
///
/// Handles:
/// - Ball tracking
/// - Difficulty-based behavior
/// - Reaction delays
/// - Movement speed
/// - Prediction logic
class AiPaddleService {
  // ============================================================================
  // Constants
  // ============================================================================

  /// Minimum distance threshold for AI to react (normalized)
  static const double minReactionDistance = 0.3;

  /// Prediction multiplier for AI difficulty
  static const double predictionMultiplier = 1.5;

  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Updates AI paddle position based on ball tracking
  PaddleEntity updatePaddle({
    required PaddleEntity aiPaddle,
    required BallEntity ball,
    required GameDifficulty difficulty,
  }) {
    final targetY = calculateTargetY(
      ball: ball,
      difficulty: difficulty,
    );

    return moveTowardsTarget(
      paddle: aiPaddle,
      targetY: targetY,
      speed: difficulty.aiSpeed,
      reactionDelay: difficulty.aiReactionDelay,
    );
  }

  /// Calculates target Y position for AI to move towards
  double calculateTargetY({
    required BallEntity ball,
    required GameDifficulty difficulty,
  }) {
    // For harder difficulties, predict future position
    if (difficulty == GameDifficulty.hard && ball.velocityX > 0) {
      return predictBallPosition(ball: ball);
    }

    // For easier difficulties, just track ball's current Y
    return ball.y;
  }

  /// Moves paddle towards target position
  PaddleEntity moveTowardsTarget({
    required PaddleEntity paddle,
    required double targetY,
    required double speed,
    required double reactionDelay,
  }) {
    final currentY = paddle.y;
    final difference = (targetY - currentY).abs();

    // If within reaction delay zone, don't move
    if (difference <= reactionDelay) {
      return paddle;
    }

    // Move towards target
    if (targetY < currentY) {
      return paddle.moveUp(speed);
    } else if (targetY > currentY) {
      return paddle.moveDown(speed);
    }

    return paddle;
  }

  // ============================================================================
  // Prediction Logic
  // ============================================================================

  /// Predicts where ball will be when it reaches AI's side
  double predictBallPosition({required BallEntity ball}) {
    if (ball.velocityX <= 0) {
      return ball.y; // Ball not moving towards AI
    }

    // Simple linear prediction
    final distanceToAi = 0.95 - ball.x; // AI paddle at x=0.95
    final timeToReach = distanceToAi / ball.velocityX;
    final predictedY = ball.y + (ball.velocityY * timeToReach);

    // Clamp to valid range
    return predictedY.clamp(0.0, 1.0);
  }

  /// Advanced prediction considering bounces
  double predictWithBounces({
    required BallEntity ball,
    int maxBounces = 2,
  }) {
    var predictedBall = ball;
    var bounceCount = 0;

    // Simulate ball movement until it reaches AI side
    while (predictedBall.x < 0.95 && bounceCount <= maxBounces) {
      predictedBall = predictedBall.move();

      // Check for vertical bounces
      if (predictedBall.y <= 0.0 || predictedBall.y >= 1.0) {
        predictedBall = predictedBall.bounceVertical();
        bounceCount++;
      }

      // Safety check to prevent infinite loop
      if (predictedBall.velocityX <= 0) break;
    }

    return predictedBall.y.clamp(0.0, 1.0);
  }

  // ============================================================================
  // Decision Making
  // ============================================================================

  /// Determines if AI should move based on ball state
  AiDecision makeDecision({
    required PaddleEntity aiPaddle,
    required BallEntity ball,
    required GameDifficulty difficulty,
  }) {
    // Check if ball is approaching
    final isApproaching = ball.velocityX > 0;

    if (!isApproaching) {
      return const AiDecision(
        shouldMove: false,
        reason: 'Ball moving away',
      );
    }

    // Check distance
    final distance = (ball.x - 0.95).abs();
    if (distance > minReactionDistance) {
      return const AiDecision(
        shouldMove: false,
        reason: 'Ball too far',
      );
    }

    // Calculate target
    final targetY = calculateTargetY(ball: ball, difficulty: difficulty);
    final currentY = aiPaddle.y;
    final difference = (targetY - currentY).abs();

    // Check reaction delay
    if (difference <= difficulty.aiReactionDelay) {
      return const AiDecision(
        shouldMove: false,
        reason: 'Within reaction delay zone',
      );
    }

    // Should move
    return AiDecision(
      shouldMove: true,
      targetY: targetY,
      direction: targetY < currentY ? PaddleDirection.up : PaddleDirection.down,
      reason: 'Tracking ball',
    );
  }

  // ============================================================================
  // Behavior Patterns
  // ============================================================================

  /// Gets AI behavior based on difficulty
  AiBehavior getBehavior(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return const AiBehavior(
          usesPrediction: false,
          reactionSpeed: 0.6,
          accuracy: 0.7,
          description: 'Slow reaction, follows ball directly',
        );

      case GameDifficulty.medium:
        return const AiBehavior(
          usesPrediction: false,
          reactionSpeed: 0.8,
          accuracy: 0.85,
          description: 'Moderate reaction, follows ball',
        );

      case GameDifficulty.hard:
        return const AiBehavior(
          usesPrediction: true,
          reactionSpeed: 1.0,
          accuracy: 0.95,
          description: 'Fast reaction, predicts ball position',
        );
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Checks if AI can reach target in time
  bool canReachTarget({
    required PaddleEntity paddle,
    required double targetY,
    required double speed,
    required int frames,
  }) {
    final currentY = paddle.y;
    final distance = (targetY - currentY).abs();
    final maxDistance = speed * frames;

    return distance <= maxDistance;
  }

  /// Calculates optimal speed to reach target
  double calculateOptimalSpeed({
    required PaddleEntity paddle,
    required double targetY,
    required int frames,
  }) {
    if (frames <= 0) return 0.0;

    final currentY = paddle.y;
    final distance = (targetY - currentY).abs();

    return distance / frames;
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets AI paddle statistics
  AiStatistics getStatistics({
    required PaddleEntity aiPaddle,
    required BallEntity ball,
    required GameDifficulty difficulty,
  }) {
    final targetY = calculateTargetY(ball: ball, difficulty: difficulty);
    final distanceToTarget = (aiPaddle.y - targetY).abs();
    final behavior = getBehavior(difficulty);
    final decision = makeDecision(
      aiPaddle: aiPaddle,
      ball: ball,
      difficulty: difficulty,
    );

    return AiStatistics(
      currentY: aiPaddle.y,
      targetY: targetY,
      distanceToTarget: distanceToTarget,
      isMoving: decision.shouldMove,
      direction: decision.direction,
      behavior: behavior,
      distanceToBall: (ball.x - 0.95).abs(),
      ballApproaching: ball.velocityX > 0,
    );
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates AI paddle state
  AiValidation validateState({
    required PaddleEntity paddle,
    required GameDifficulty difficulty,
  }) {
    final errors = <String>[];

    if (!paddle.isLeft) {
      // AI should be on right side
      if (paddle.y < 0.0 || paddle.y > 1.0) {
        errors.add('AI paddle Y out of bounds: ${paddle.y}');
      }
    } else {
      errors.add('AI paddle is on wrong side (left)');
    }

    if (difficulty.aiSpeed <= 0) {
      errors.add('AI speed must be positive: ${difficulty.aiSpeed}');
    }

    return AiValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ============================================================================
  // Testing Utilities
  // ============================================================================

  /// Creates AI paddle with test configuration
  PaddleEntity createTestPaddle({
    double y = 0.5,
    double width = 15.0,
    double height = 100.0,
  }) {
    return PaddleEntity(
      y: y,
      width: width,
      height: height,
      isLeft: false,
    );
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// AI decision result
class AiDecision {
  final bool shouldMove;
  final double? targetY;
  final PaddleDirection? direction;
  final String reason;

  const AiDecision({
    required this.shouldMove,
    this.targetY,
    this.direction,
    required this.reason,
  });
}

/// AI behavior characteristics
class AiBehavior {
  final bool usesPrediction;
  final double reactionSpeed;
  final double accuracy;
  final String description;

  const AiBehavior({
    required this.usesPrediction,
    required this.reactionSpeed,
    required this.accuracy,
    required this.description,
  });
}

/// Statistics about AI paddle
class AiStatistics {
  final double currentY;
  final double targetY;
  final double distanceToTarget;
  final bool isMoving;
  final PaddleDirection? direction;
  final AiBehavior behavior;
  final double distanceToBall;
  final bool ballApproaching;

  const AiStatistics({
    required this.currentY,
    required this.targetY,
    required this.distanceToTarget,
    required this.isMoving,
    required this.direction,
    required this.behavior,
    required this.distanceToBall,
    required this.ballApproaching,
  });

  /// Checks if AI is aligned with target
  bool get isAligned => distanceToTarget < 0.02;

  /// Gets tracking efficiency (0-1)
  double get trackingEfficiency {
    if (distanceToTarget == 0) return 1.0;
    return (1.0 - distanceToTarget).clamp(0.0, 1.0);
  }
}

/// Validation result for AI state
class AiValidation {
  final bool isValid;
  final List<String> errors;

  const AiValidation({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}
