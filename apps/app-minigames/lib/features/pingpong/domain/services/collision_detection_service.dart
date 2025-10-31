import 'package:injectable/injectable.dart';

import '../entities/ball_entity.dart';
import '../entities/paddle_entity.dart';

/// Service responsible for collision detection between ball and paddles
///
/// Handles:
/// - Ball-paddle collision detection
/// - Hit position calculation
/// - Collision response
/// - Rally tracking
@lazySingleton
class CollisionDetectionService {
  // ============================================================================
  // Constants
  // ============================================================================

  /// Normalization factor for pixel to normalized coordinates
  static const double normalizationFactor = 1000.0;

  /// Left paddle X position (normalized)
  static const double leftPaddleX = 0.05;

  /// Right paddle X position (normalized)
  static const double rightPaddleX = 0.95;

  // ============================================================================
  // Core Methods
  // ============================================================================

  /// Checks if paddle collides with ball
  bool checkCollision({
    required PaddleEntity paddle,
    required BallEntity ball,
  }) {
    final paddleX = paddle.isLeft ? leftPaddleX : rightPaddleX;
    final paddleTop = paddle.y - paddle.height / 2 / normalizationFactor;
    final paddleBottom = paddle.y + paddle.height / 2 / normalizationFactor;

    final ballRadius = ball.radius / normalizationFactor;
    final ballLeft = ball.x - ballRadius;
    final ballRight = ball.x + ballRadius;
    final ballTop = ball.y - ballRadius;
    final ballBottom = ball.y + ballRadius;

    final paddleWidthNorm = paddle.width / normalizationFactor;

    final horizontalOverlap = paddle.isLeft
        ? (ballLeft <= paddleX + paddleWidthNorm && ballRight >= paddleX)
        : (ballRight >= paddleX - paddleWidthNorm && ballLeft <= paddleX);

    final verticalOverlap = ballBottom >= paddleTop && ballTop <= paddleBottom;

    return horizontalOverlap && verticalOverlap;
  }

  /// Calculates hit position on paddle (-1.0 to 1.0)
  ///
  /// -1.0 = top of paddle
  ///  0.0 = center of paddle
  ///  1.0 = bottom of paddle
  double calculateHitPosition({
    required PaddleEntity paddle,
    required BallEntity ball,
  }) {
    final paddleHalfHeight = paddle.height / 2 / normalizationFactor;
    final relativeY = (ball.y - paddle.y) / paddleHalfHeight;
    return relativeY.clamp(-1.0, 1.0);
  }

  /// Checks collision with any paddle and returns result
  CollisionResult checkPaddleCollisions({
    required PaddleEntity playerPaddle,
    required PaddleEntity aiPaddle,
    required BallEntity ball,
  }) {
    // Check player paddle
    if (checkCollision(paddle: playerPaddle, ball: ball)) {
      final hitPosition = calculateHitPosition(
        paddle: playerPaddle,
        ball: ball,
      );

      return CollisionResult(
        hasCollision: true,
        collidedPaddle: CollidedPaddle.player,
        hitPosition: hitPosition,
      );
    }

    // Check AI paddle
    if (checkCollision(paddle: aiPaddle, ball: ball)) {
      final hitPosition = calculateHitPosition(
        paddle: aiPaddle,
        ball: ball,
      );

      return CollisionResult(
        hasCollision: true,
        collidedPaddle: CollidedPaddle.ai,
        hitPosition: hitPosition,
      );
    }

    return const CollisionResult(hasCollision: false);
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Gets distance between ball and paddle
  double getDistanceToPaddle({
    required PaddleEntity paddle,
    required BallEntity ball,
  }) {
    final paddleX = paddle.isLeft ? leftPaddleX : rightPaddleX;
    final horizontalDistance = (ball.x - paddleX).abs();
    final verticalDistance = (ball.y - paddle.y).abs();

    // Pythagorean distance
    return sqrt(
      horizontalDistance * horizontalDistance +
          verticalDistance * verticalDistance,
    );
  }

  /// Checks if ball is approaching paddle
  bool isApproachingPaddle({
    required PaddleEntity paddle,
    required BallEntity ball,
  }) {
    if (paddle.isLeft) {
      return ball.velocityX < 0; // Ball moving left
    } else {
      return ball.velocityX > 0; // Ball moving right
    }
  }

  /// Gets minimum distance to any paddle
  double getMinDistanceToPaddles({
    required PaddleEntity playerPaddle,
    required PaddleEntity aiPaddle,
    required BallEntity ball,
  }) {
    final distanceToPlayer = getDistanceToPaddle(
      paddle: playerPaddle,
      ball: ball,
    );
    final distanceToAi = getDistanceToPaddle(
      paddle: aiPaddle,
      ball: ball,
    );

    return distanceToPlayer < distanceToAi ? distanceToPlayer : distanceToAi;
  }

  // ============================================================================
  // Collision Zone Detection
  // ============================================================================

  /// Checks if ball is in collision zone (near paddle)
  bool isInCollisionZone({
    required PaddleEntity paddle,
    required BallEntity ball,
    double zoneThreshold = 0.05,
  }) {
    final distance = getDistanceToPaddle(paddle: paddle, ball: ball);
    return distance <= zoneThreshold;
  }

  /// Gets collision zone info
  CollisionZoneInfo getCollisionZoneInfo({
    required PaddleEntity paddle,
    required BallEntity ball,
  }) {
    final distance = getDistanceToPaddle(paddle: paddle, ball: ball);
    final isApproaching = isApproachingPaddle(paddle: paddle, ball: ball);
    final inZone = isInCollisionZone(paddle: paddle, ball: ball);

    return CollisionZoneInfo(
      distance: distance,
      isApproaching: isApproaching,
      inZone: inZone,
      willCollide: isApproaching && inZone,
    );
  }

  // ============================================================================
  // Hit Quality Analysis
  // ============================================================================

  /// Analyzes hit quality based on position
  HitQuality analyzeHitQuality(double hitPosition) {
    final absPosition = hitPosition.abs();

    if (absPosition <= 0.2) {
      return HitQuality.perfect; // Center hit
    } else if (absPosition <= 0.5) {
      return HitQuality.good; // Mid hit
    } else if (absPosition <= 0.8) {
      return HitQuality.poor; // Edge hit
    } else {
      return HitQuality.critical; // Extreme edge hit
    }
  }

  /// Gets hit quality stats
  HitQualityStats getHitQualityStats(double hitPosition) {
    final quality = analyzeHitQuality(hitPosition);
    final absPosition = hitPosition.abs();

    return HitQualityStats(
      quality: quality,
      hitPosition: hitPosition,
      centerDistance: absPosition,
      isPerfectHit: quality == HitQuality.perfect,
      isEdgeHit: quality == HitQuality.critical,
    );
  }

  // ============================================================================
  // Rally Tracking
  // ============================================================================

  /// Creates rally info after successful hit
  RallyInfo createRallyInfo({
    required int currentRally,
    required int totalHits,
    required CollidedPaddle hitBy,
    required double hitPosition,
  }) {
    return RallyInfo(
      currentRally: currentRally + 1,
      totalHits: totalHits + 1,
      lastHitBy: hitBy,
      lastHitPosition: hitPosition,
      hitQuality: analyzeHitQuality(hitPosition),
    );
  }

  // ============================================================================
  // Statistics Methods
  // ============================================================================

  /// Gets collision statistics
  CollisionStatistics getStatistics({
    required PaddleEntity playerPaddle,
    required PaddleEntity aiPaddle,
    required BallEntity ball,
    required int totalHits,
    required int currentRally,
  }) {
    final distanceToPlayer = getDistanceToPaddle(
      paddle: playerPaddle,
      ball: ball,
    );
    final distanceToAi = getDistanceToPaddle(
      paddle: aiPaddle,
      ball: ball,
    );

    final approachingPlayer = isApproachingPaddle(
      paddle: playerPaddle,
      ball: ball,
    );
    final approachingAi = isApproachingPaddle(
      paddle: aiPaddle,
      ball: ball,
    );

    return CollisionStatistics(
      distanceToPlayerPaddle: distanceToPlayer,
      distanceToAiPaddle: distanceToAi,
      approachingPlayer: approachingPlayer,
      approachingAi: approachingAi,
      totalHits: totalHits,
      currentRally: currentRally,
      averageHitsPerRally:
          totalHits > 0 && currentRally > 0 ? totalHits / currentRally : 0.0,
    );
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validates collision detection state
  CollisionValidation validateCollisionState({
    required PaddleEntity playerPaddle,
    required PaddleEntity aiPaddle,
    required BallEntity ball,
  }) {
    final errors = <String>[];

    // Check if both paddles claim collision (impossible)
    final playerCollision = checkCollision(paddle: playerPaddle, ball: ball);
    final aiCollision = checkCollision(paddle: aiPaddle, ball: ball);

    if (playerCollision && aiCollision) {
      errors.add('Ball colliding with both paddles simultaneously');
    }

    return CollisionValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

// Helper function for distance calculation
double sqrt(double value) => value < 0 ? 0 : value.abs().sqrt();

extension on double {
  double sqrt() {
    double x = this;
    if (x == 0) return 0;
    double result = x;
    double last;
    do {
      last = result;
      result = (result + x / result) / 2;
    } while ((result - last).abs() > 0.000001);
    return result;
  }
}

// ==============================================================================
// Models
// ==============================================================================

/// Result of collision check
class CollisionResult {
  final bool hasCollision;
  final CollidedPaddle? collidedPaddle;
  final double? hitPosition;

  const CollisionResult({
    required this.hasCollision,
    this.collidedPaddle,
    this.hitPosition,
  });
}

/// Which paddle was hit
enum CollidedPaddle {
  player,
  ai;

  bool get isPlayer => this == CollidedPaddle.player;
  bool get isAi => this == CollidedPaddle.ai;
}

/// Information about collision zone
class CollisionZoneInfo {
  final double distance;
  final bool isApproaching;
  final bool inZone;
  final bool willCollide;

  const CollisionZoneInfo({
    required this.distance,
    required this.isApproaching,
    required this.inZone,
    required this.willCollide,
  });
}

/// Quality of paddle hit
enum HitQuality {
  perfect,
  good,
  poor,
  critical;

  String get label {
    switch (this) {
      case HitQuality.perfect:
        return 'Perfect';
      case HitQuality.good:
        return 'Good';
      case HitQuality.poor:
        return 'Poor';
      case HitQuality.critical:
        return 'Critical';
    }
  }
}

/// Statistics about hit quality
class HitQualityStats {
  final HitQuality quality;
  final double hitPosition;
  final double centerDistance;
  final bool isPerfectHit;
  final bool isEdgeHit;

  const HitQualityStats({
    required this.quality,
    required this.hitPosition,
    required this.centerDistance,
    required this.isPerfectHit,
    required this.isEdgeHit,
  });
}

/// Information about rally
class RallyInfo {
  final int currentRally;
  final int totalHits;
  final CollidedPaddle lastHitBy;
  final double lastHitPosition;
  final HitQuality hitQuality;

  const RallyInfo({
    required this.currentRally,
    required this.totalHits,
    required this.lastHitBy,
    required this.lastHitPosition,
    required this.hitQuality,
  });
}

/// Statistics about collisions
class CollisionStatistics {
  final double distanceToPlayerPaddle;
  final double distanceToAiPaddle;
  final bool approachingPlayer;
  final bool approachingAi;
  final int totalHits;
  final int currentRally;
  final double averageHitsPerRally;

  const CollisionStatistics({
    required this.distanceToPlayerPaddle,
    required this.distanceToAiPaddle,
    required this.approachingPlayer,
    required this.approachingAi,
    required this.totalHits,
    required this.currentRally,
    required this.averageHitsPerRally,
  });
}

/// Validation result for collision state
class CollisionValidation {
  final bool isValid;
  final List<String> errors;

  const CollisionValidation({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.join('; ');
}
