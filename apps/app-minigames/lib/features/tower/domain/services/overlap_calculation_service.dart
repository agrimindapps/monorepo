
/// Model representing overlap calculation result
class OverlapResult {
  /// The calculated overlap distance in pixels
  final double overlap;

  /// The precision ratio (0.0 to 1.0)
  final double precision;

  /// Whether this is a perfect placement (precision >= 0.9)
  final bool isPerfect;

  /// Whether the game should end (overlap <= 0)
  final bool isGameOver;

  const OverlapResult({
    required this.overlap,
    required this.precision,
    required this.isPerfect,
    required this.isGameOver,
  });
}

/// Service responsible for calculating block overlap and precision
///
/// This service handles all calculations related to how well blocks align:
/// - Overlap distance calculation
/// - Precision ratio calculation
/// - Perfect placement detection
/// - Game over condition checking
class OverlapCalculationService {
  /// Threshold for perfect placement (90% precision)
  static const double perfectPlacementThreshold = 0.9;

  /// Calculates overlap and precision when a block is dropped
  ///
  /// The overlap is the amount of the current block that sits on top
  /// of the previous block. If there's no overlap, the game ends.
  ///
  /// Precision is a ratio from 0.0 to 1.0 representing how centered
  /// the block is placed.
  ///
  /// [currentBlockWidth] Width of the block being dropped
  /// [currentBlockPosX] X position of the current block's left edge
  /// [lastBlockX] X position of the previous block's left edge
  ///
  /// Returns an [OverlapResult] containing overlap, precision, and status flags
  OverlapResult calculateOverlap({
    required double currentBlockWidth,
    required double currentBlockPosX,
    required double lastBlockX,
  }) {
    // Calculate the horizontal distance between block edges
    final positionDifference = (currentBlockPosX - lastBlockX).abs();

    // Overlap is the width minus the position difference
    // Positive overlap means blocks are touching
    // Zero or negative means they don't touch (game over)
    final overlap = currentBlockWidth - positionDifference;

    // Calculate precision as a ratio of overlap to width
    // This gives a score from 0.0 (no overlap) to 1.0 (perfect center)
    final precision = overlap > 0 ? overlap / currentBlockWidth : 0.0;

    // Check if this placement is perfect (90% or better precision)
    final isPerfect = precision >= perfectPlacementThreshold;

    // Game ends if blocks don't overlap
    final isGameOver = overlap <= 0;

    return OverlapResult(
      overlap: overlap,
      precision: precision,
      isPerfect: isPerfect,
      isGameOver: isGameOver,
    );
  }

  /// Validates if an overlap value represents a valid placement
  ///
  /// [overlap] The overlap distance to validate
  ///
  /// Returns true if the overlap is positive (blocks touch)
  bool isValidPlacement(double overlap) {
    return overlap > 0;
  }

  /// Checks if a precision value qualifies as perfect placement
  ///
  /// [precision] The precision ratio to check (0.0 to 1.0)
  ///
  /// Returns true if precision meets or exceeds the threshold
  bool isPerfectPlacement(double precision) {
    return precision >= perfectPlacementThreshold;
  }

  /// Calculates the precision percentage for display
  ///
  /// [precision] The precision ratio (0.0 to 1.0)
  ///
  /// Returns the precision as a percentage (0 to 100)
  int getPrecisionPercentage(double precision) {
    return (precision * 100).round().clamp(0, 100);
  }

  /// Calculates the quality grade based on precision
  ///
  /// [precision] The precision ratio (0.0 to 1.0)
  ///
  /// Returns a grade string: 'Perfeito', 'Excelente', 'Bom', 'Regular', or 'Fraco'
  String getPrecisionGrade(double precision) {
    if (precision >= 0.9) {
      return 'Perfeito';
    } else if (precision >= 0.75) {
      return 'Excelente';
    } else if (precision >= 0.6) {
      return 'Bom';
    } else if (precision >= 0.4) {
      return 'Regular';
    } else {
      return 'Fraco';
    }
  }

  /// Calculates the new block width after a drop
  ///
  /// In Tower games, blocks often shrink to match the overlap width
  /// for increased difficulty as the game progresses.
  ///
  /// [currentWidth] The current block width
  /// [overlap] The calculated overlap distance
  ///
  /// Returns the new block width (equal to overlap if positive, or current width if no shrinking)
  double calculateNewBlockWidth({
    required double currentWidth,
    required double overlap,
  }) {
    // If overlap is positive, the new block width equals the overlap
    // This makes the game progressively harder as blocks get smaller
    return overlap > 0 ? overlap : currentWidth;
  }

  /// Calculates the new block X position after alignment
  ///
  /// When a block is placed, it may need to be aligned to sit
  /// perfectly on top of the previous block.
  ///
  /// [currentBlockPosX] Current X position of the block
  /// [lastBlockX] X position of the previous block
  /// [currentBlockWidth] Width of the current block
  /// [overlap] The calculated overlap distance
  ///
  /// Returns the aligned X position for the placed block
  double calculateAlignedPosition({
    required double currentBlockPosX,
    required double lastBlockX,
    required double currentBlockWidth,
    required double overlap,
  }) {
    // Determine which direction to align
    if (currentBlockPosX >= lastBlockX) {
      // Current block is to the right, align to left edge
      return lastBlockX;
    } else {
      // Current block is to the left, align to right edge
      // This ensures the block sits on top correctly
      return lastBlockX - (currentBlockWidth - overlap);
    }
  }
}
