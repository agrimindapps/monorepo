// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing a pipe obstacle in the Flappy Bird game
class PipeEntity extends Equatable {
  /// Unique identifier
  final String id;

  /// Horizontal position (pixels from left)
  final double x;

  /// Top pipe height (pixels from top)
  final double topHeight;

  /// Whether the bird has passed this pipe (for scoring)
  final bool passed;

  /// Pipe width (pixels)
  final double width;

  /// Screen height (for calculating bottom pipe)
  final double screenHeight;

  /// Gap size (as percentage of screen height)
  final double gapSize;

  const PipeEntity({
    required this.id,
    required this.x,
    required this.topHeight,
    required this.screenHeight,
    required this.gapSize,
    this.passed = false,
    this.width = 80.0,
  });

  /// Calculate bottom pipe height
  double get bottomHeight {
    return screenHeight - topHeight - (screenHeight * gapSize);
  }

  /// Calculate gap center Y position
  double get gapCenterY {
    return topHeight + (screenHeight * gapSize) / 2;
  }

  /// Move pipe to the left (returns new state)
  PipeEntity moveLeft(double speed) {
    return copyWith(x: x - speed);
  }

  /// Check if pipe is off-screen (left side)
  bool isOffScreen() {
    return x + width < 0;
  }

  /// Check if bird has passed this pipe (for scoring)
  bool checkPassed(double birdX) {
    return !passed && birdX > x + width;
  }

  /// Mark pipe as passed
  PipeEntity markPassed() {
    return copyWith(passed: true);
  }

  /// Check collision with bird
  bool checkCollision(double birdX, double birdY, double birdSize) {
    // Adjusted bird size for more forgiving collision (70% of actual size)
    final adjustedSize = birdSize * 0.7;

    // Check if bird is horizontally within pipe bounds
    final horizontalOverlap = birdX + adjustedSize / 2 > x &&
        birdX - adjustedSize / 2 < x + width;

    if (!horizontalOverlap) return false;

    // Check if bird is vertically colliding (outside gap)
    final topCollision = birdY - adjustedSize / 2 < topHeight;
    final bottomCollision = birdY + adjustedSize / 2 > screenHeight - bottomHeight;

    return topCollision || bottomCollision;
  }

  /// Create a copy with modified fields
  PipeEntity copyWith({
    String? id,
    double? x,
    double? topHeight,
    double? screenHeight,
    double? gapSize,
    bool? passed,
    double? width,
  }) {
    return PipeEntity(
      id: id ?? this.id,
      x: x ?? this.x,
      topHeight: topHeight ?? this.topHeight,
      screenHeight: screenHeight ?? this.screenHeight,
      gapSize: gapSize ?? this.gapSize,
      passed: passed ?? this.passed,
      width: width ?? this.width,
    );
  }

  @override
  List<Object?> get props => [id, x, topHeight, screenHeight, gapSize, passed, width];
}
