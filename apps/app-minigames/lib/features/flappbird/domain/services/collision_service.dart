import 'package:injectable/injectable.dart';

import '../entities/bird_entity.dart';
import '../entities/pipe_entity.dart';

/// Service responsible for collision detection
/// Follows SRP by handling only collision calculations
@lazySingleton
class CollisionService {
  /// Collision box padding (makes hitbox slightly smaller for fairness)
  static const double collisionPadding = 2.0;

  /// Checks collision between bird and a pipe
  bool checkBirdPipeCollision({
    required BirdEntity bird,
    required PipeEntity pipe,
    required double birdX,
  }) {
    // Apply collision padding for fairer gameplay
    final birdLeft = birdX + collisionPadding;
    final birdRight = birdX + bird.size - collisionPadding;
    final birdTop = bird.y + collisionPadding;
    final birdBottom = bird.y + bird.size - collisionPadding;

    // Pipe boundaries
    final pipeLeft = pipe.x;
    final pipeRight = pipe.x + pipe.width;

    // Check if bird is horizontally aligned with pipe
    if (birdRight < pipeLeft || birdLeft > pipeRight) {
      return false; // Bird not in pipe's X range
    }

    // Check collision with top pipe
    if (birdTop < pipe.topHeight) {
      return true; // Hit top pipe
    }

    // Check collision with bottom pipe
    final gapHeight = pipe.screenHeight * pipe.gapSize;
    final bottomPipeTop = pipe.topHeight + gapHeight;
    if (birdBottom > bottomPipeTop) {
      return true; // Hit bottom pipe
    }

    return false; // Bird is in the gap
  }

  /// Checks collision with any pipe in the list
  bool checkBirdPipesCollision({
    required BirdEntity bird,
    required List<PipeEntity> pipes,
    required double birdX,
  }) {
    for (final pipe in pipes) {
      if (checkBirdPipeCollision(
        bird: bird,
        pipe: pipe,
        birdX: birdX,
      )) {
        return true;
      }
    }
    return false;
  }

  /// Checks if bird hit ground
  bool checkGroundCollision({
    required BirdEntity bird,
    required double playAreaHeight,
  }) {
    return bird.y + bird.size >= playAreaHeight;
  }

  /// Checks if bird hit ceiling
  bool checkCeilingCollision({
    required BirdEntity bird,
  }) {
    return bird.y <= 0;
  }

  /// Checks all collision types
  CollisionResult checkAllCollisions({
    required BirdEntity bird,
    required List<PipeEntity> pipes,
    required double birdX,
    required double playAreaHeight,
  }) {
    // Check boundary collisions first (faster)
    if (checkGroundCollision(bird: bird, playAreaHeight: playAreaHeight)) {
      return CollisionResult(
        hasCollision: true,
        type: CollisionType.ground,
      );
    }

    if (checkCeilingCollision(bird: bird)) {
      return CollisionResult(
        hasCollision: true,
        type: CollisionType.ceiling,
      );
    }

    // Check pipe collisions
    for (final pipe in pipes) {
      if (checkBirdPipeCollision(bird: bird, pipe: pipe, birdX: birdX)) {
        return CollisionResult(
          hasCollision: true,
          type: CollisionType.pipe,
          collidedPipe: pipe,
        );
      }
    }

    return CollisionResult(hasCollision: false);
  }

  /// Calculates distance to nearest obstacle
  double getDistanceToNearestObstacle({
    required BirdEntity bird,
    required List<PipeEntity> pipes,
    required double birdX,
    required double playAreaHeight,
  }) {
    double minDistance = double.infinity;

    // Distance to ground
    final groundDistance = playAreaHeight - (bird.y + bird.size);
    minDistance = min(minDistance, groundDistance);

    // Distance to ceiling
    final ceilingDistance = bird.y;
    minDistance = min(minDistance, ceilingDistance);

    // Distance to pipes
    for (final pipe in pipes) {
      // Only check pipes ahead of bird
      if (pipe.x + pipe.width > birdX) {
        // Distance to pipe's left edge
        final horizontalDistance = pipe.x - (birdX + bird.size);

        if (horizontalDistance > 0) {
          minDistance = min(minDistance, horizontalDistance);
        } else {
          // Bird is between pipe edges, check vertical distance
          if (bird.y < pipe.topHeight) {
            // Above gap, distance to top pipe
            final distToTop = pipe.topHeight - (bird.y + bird.size);
            minDistance = min(minDistance, distToTop);
          } else {
            final gapHeight = pipe.screenHeight * pipe.gapSize;
            if (bird.y + bird.size > pipe.topHeight + gapHeight) {
              // Below gap, distance to bottom pipe
              final distToBottom = (bird.y) - (pipe.topHeight + gapHeight);
              minDistance = min(minDistance, distToBottom);
            }
          }
        }
      }
    }

    return minDistance;
  }

  /// Gets safe zone information (how much space bird has)
  SafeZoneInfo getSafeZoneInfo({
    required BirdEntity bird,
    required List<PipeEntity> pipes,
    required double birdX,
    required double playAreaHeight,
  }) {
    final distanceToGround = playAreaHeight - (bird.y + bird.size);
    final distanceToCeiling = bird.y;
    final distanceToNearestObstacle = getDistanceToNearestObstacle(
      bird: bird,
      pipes: pipes,
      birdX: birdX,
      playAreaHeight: playAreaHeight,
    );

    return SafeZoneInfo(
      distanceToGround: distanceToGround,
      distanceToCeiling: distanceToCeiling,
      distanceToNearestObstacle: distanceToNearestObstacle,
      isSafe: distanceToNearestObstacle > bird.size,
      isInDanger: distanceToNearestObstacle < bird.size * 2,
    );
  }

  /// Validates collision padding
  bool validateCollisionPadding(double padding) {
    return padding >= 0 && padding < 10;
  }

  double min(double a, double b) => a < b ? a : b;
}

// Models

enum CollisionType {
  pipe,
  ground,
  ceiling,
}

class CollisionResult {
  final bool hasCollision;
  final CollisionType? type;
  final PipeEntity? collidedPipe;

  CollisionResult({
    required this.hasCollision,
    this.type,
    this.collidedPipe,
  });
}

class SafeZoneInfo {
  final double distanceToGround;
  final double distanceToCeiling;
  final double distanceToNearestObstacle;
  final bool isSafe;
  final bool isInDanger;

  SafeZoneInfo({
    required this.distanceToGround,
    required this.distanceToCeiling,
    required this.distanceToNearestObstacle,
    required this.isSafe,
    required this.isInDanger,
  });
}
