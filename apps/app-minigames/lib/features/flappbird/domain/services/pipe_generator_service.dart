import 'dart:math';
import 'package:injectable/injectable.dart';

import '../entities/pipe_entity.dart';
import '../entities/enums.dart';

/// Service responsible for pipe generation and management
/// Follows SRP by handling only pipe operations
@lazySingleton
class PipeGeneratorService {
  final Random _random = Random();

  /// Pipe spacing (distance between pipes)
  static const double defaultPipeSpacing = 300.0;

  /// Spawn distance threshold
  static const double defaultSpawnDistance = 50.0;

  /// Pipe width
  static const double pipeWidth = 80.0;

  /// Minimum top height percentage (gap from top)
  static const double minTopHeightPercent = 0.1;

  /// Maximum top height percentage (gap from bottom)
  /// This prevents gaps that are too easy to pass through
  static const double maxTopHeightPercent = 0.8;

  /// Creates a new pipe at the right edge of screen
  /// Ensures gap size is balanced and achievable at all difficulty levels
  PipeEntity createPipe({
    required String id,
    required double screenWidth,
    required double screenHeight,
    required FlappyDifficulty difficulty,
  }) {
    final gapSize = difficulty.gapSize;
    final minTopHeight = screenHeight * minTopHeightPercent;

    // Ensure max top height doesn't create impossible gaps
    // maxTopHeight = screen * maxTopHeightPercent, but ensure gap fits
    final maxPossibleTop = screenHeight * (1 - gapSize) - minTopHeight;
    final maxTopHeight = minTopHeight + maxPossibleTop * 0.9; // Use 90% of range

    final topHeight =
        minTopHeight + _random.nextDouble() * (maxTopHeight - minTopHeight);

    return PipeEntity(
      id: id,
      x: screenWidth + 50,
      topHeight: topHeight,
      screenHeight: screenHeight,
      gapSize: gapSize,
      passed: false,
    );
  }

  /// Moves pipe to the left
  PipeEntity movePipe({
    required PipeEntity pipe,
    required double speed,
  }) {
    return pipe.moveLeft(speed);
  }

  /// Checks if new pipe should be spawned
  bool shouldSpawnNewPipe({
    required List<PipeEntity> pipes,
    required double screenWidth,
    double pipeSpacing = defaultPipeSpacing,
    double spawnDistance = defaultSpawnDistance,
  }) {
    if (pipes.isEmpty) return true;

    final lastPipe = pipes.last;
    return lastPipe.x < screenWidth - pipeSpacing + spawnDistance;
  }

  /// Removes off-screen pipes
  List<PipeEntity> removeOffScreenPipes(List<PipeEntity> pipes) {
    return pipes.where((pipe) => !pipe.isOffScreen()).toList();
  }

  /// Updates pipe passed status and returns score increase
  (PipeEntity, int) updatePipePassed({
    required PipeEntity pipe,
    required double birdX,
  }) {
    if (pipe.checkPassed(birdX)) {
      return (pipe.markPassed(), 1);
    }
    return (pipe, 0);
  }

  /// Creates initial set of pipes
  List<PipeEntity> createInitialPipes({
    required double screenWidth,
    required double screenHeight,
    required FlappyDifficulty difficulty,
    int count = 3,
  }) {
    final pipes = <PipeEntity>[];

    for (int i = 0; i < count; i++) {
      final x = screenWidth + (i * defaultPipeSpacing);

      final pipe = createPipe(
        id: 'pipe_$i',
        screenWidth: x - 50, // Adjust for initial position
        screenHeight: screenHeight,
        difficulty: difficulty,
      );

      pipes.add(pipe);
    }

    return pipes;
  }

  /// Gets next pipe that bird will encounter
  PipeEntity? getNextPipe({
    required List<PipeEntity> pipes,
    required double birdX,
  }) {
    for (final pipe in pipes) {
      if (pipe.x + pipeWidth > birdX && !pipe.passed) {
        return pipe;
      }
    }
    return null;
  }

  /// Calculates distance to next pipe
  double? getDistanceToNextPipe({
    required List<PipeEntity> pipes,
    required double birdX,
  }) {
    final nextPipe = getNextPipe(pipes: pipes, birdX: birdX);
    if (nextPipe == null) return null;

    return nextPipe.x - birdX;
  }

  /// Gets gap center Y position for next pipe
  double? getNextGapCenterY({
    required List<PipeEntity> pipes,
    required double birdX,
  }) {
    final nextPipe = getNextPipe(pipes: pipes, birdX: birdX);
    if (nextPipe == null) return null;

    return nextPipe.gapCenterY;
  }

  /// Validates pipe configuration
  PipeValidation validatePipeConfig({
    required double screenWidth,
    required double screenHeight,
    required FlappyDifficulty difficulty,
  }) {
    final gapSize = difficulty.gapSize;

    if (gapSize <= 0 || gapSize >= 1) {
      return PipeValidation(
        isValid: false,
        errorMessage: 'Gap size must be between 0 and 1',
      );
    }

    final minHeight = screenHeight * minTopHeightPercent;
    final maxHeight = screenHeight * (1 - gapSize) - minHeight;

    if (maxHeight <= minHeight) {
      return PipeValidation(
        isValid: false,
        errorMessage: 'Screen too small for difficulty gap size',
      );
    }

    return PipeValidation(isValid: true);
  }

  /// Gets pipe statistics
  PipeStatistics getStatistics({
    required List<PipeEntity> pipes,
    required double birdX,
    required double screenWidth,
  }) {
    final onScreenPipes = pipes.where((p) => !p.isOffScreen()).length;
    final passedPipes = pipes.where((p) => p.passed).length;
    final nextPipe = getNextPipe(pipes: pipes, birdX: birdX);

    return PipeStatistics(
      totalPipes: pipes.length,
      onScreenPipes: onScreenPipes,
      passedPipes: passedPipes,
      distanceToNext: getDistanceToNextPipe(pipes: pipes, birdX: birdX),
      nextGapCenterY: getNextGapCenterY(pipes: pipes, birdX: birdX),
      hasNextPipe: nextPipe != null,
    );
  }

  /// Creates test pipes at specific positions
  List<PipeEntity> createTestPipes({
    required List<PipeTestConfig> configs,
    required double screenHeight,
  }) {
    return configs.map((config) {
      return PipeEntity(
        id: config.id,
        x: config.x,
        topHeight: config.topHeight,
        screenHeight: screenHeight,
        gapSize: config.gapSize,
        passed: config.passed,
      );
    }).toList();
  }
}

// Models

class PipeValidation {
  final bool isValid;
  final String? errorMessage;

  PipeValidation({
    required this.isValid,
    this.errorMessage,
  });
}

class PipeStatistics {
  final int totalPipes;
  final int onScreenPipes;
  final int passedPipes;
  final double? distanceToNext;
  final double? nextGapCenterY;
  final bool hasNextPipe;

  PipeStatistics({
    required this.totalPipes,
    required this.onScreenPipes,
    required this.passedPipes,
    required this.distanceToNext,
    required this.nextGapCenterY,
    required this.hasNextPipe,
  });
}

class PipeTestConfig {
  final String id;
  final double x;
  final double topHeight;
  final double gapSize;
  final bool passed;

  PipeTestConfig({
    required this.id,
    required this.x,
    required this.topHeight,
    required this.gapSize,
    this.passed = false,
  });
}
