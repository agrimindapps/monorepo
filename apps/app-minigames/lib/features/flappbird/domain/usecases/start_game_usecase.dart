// Package imports:
import 'package:dartz/dartz.dart';
import 'dart:math';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/game_state_entity.dart';
import '../entities/pipe_entity.dart';
import '../entities/enums.dart';
import '../services/physics_service.dart';
import '../services/pipe_generator_service.dart';

/// Use case to start a new game
/// Validates physics and difficulty parameters before starting
class StartGameUseCase {
  final PhysicsService _physicsService;
  final PipeGeneratorService _pipeGeneratorService;

  StartGameUseCase(this._physicsService, this._pipeGeneratorService);

  Future<Either<Failure, FlappyGameState>> call({
    required FlappyGameState currentState,
  }) async {
    try {
      // Validate physics parameters
      final physicsValidation = _physicsService.validatePhysics(
        gravity: PhysicsService.defaultGravity,
        jumpStrength: PhysicsService.defaultJumpStrength,
      );

      if (!physicsValidation.isValid) {
        return Left(
          ValidationFailure(
            'Invalid physics configuration: ${physicsValidation.errorMessage}',
          ),
        );
      }

      // Validate pipe configuration
      final pipeValidation = _pipeGeneratorService.validatePipeConfig(
        screenWidth: currentState.screenWidth,
        screenHeight: currentState.playAreaHeight,
        difficulty: currentState.difficulty,
      );

      if (!pipeValidation.isValid) {
        return Left(
          ValidationFailure(
            'Invalid pipe configuration: ${pipeValidation.errorMessage}',
          ),
        );
      }

      // Generate initial pipes
      final pipes = _generateInitialPipes(currentState);

      // Return new game state in "playing" status
      return Right(
        currentState.copyWith(
          pipes: pipes,
          score: 0,
          status: FlappyGameStatus.playing,
          bird: currentState.bird.copyWith(
            velocity: 0.0,
            rotation: 0.0,
          ),
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to start game: $e'));
    }
  }

  /// Generate 2 initial pipes at proper spacing
  List<PipeEntity> _generateInitialPipes(FlappyGameState state) {
    final random = Random();
    final pipes = <PipeEntity>[];

    // First pipe at screen width + 100px
    pipes.add(_createPipe(
      id: 'pipe_0',
      x: state.screenWidth + 100,
      screenHeight: state.playAreaHeight,
      gapSize: state.difficulty.gapSize,
      random: random,
    ));

    // Second pipe at 300px spacing
    pipes.add(_createPipe(
      id: 'pipe_1',
      x: state.screenWidth + 100 + 300,
      screenHeight: state.playAreaHeight,
      gapSize: state.difficulty.gapSize,
      random: random,
    ));

    return pipes;
  }

  /// Create a single pipe with random gap position
  PipeEntity _createPipe({
    required String id,
    required double x,
    required double screenHeight,
    required double gapSize,
    required Random random,
  }) {
    // Min top height: 10% of screen
    final minTopHeight = screenHeight * 0.1;
    // Max top height: ensure gap fits
    final maxTopHeight = screenHeight * (1 - gapSize) - minTopHeight;

    final topHeight = minTopHeight + random.nextDouble() * (maxTopHeight - minTopHeight);

    return PipeEntity(
      id: id,
      x: x,
      topHeight: topHeight,
      screenHeight: screenHeight,
      gapSize: gapSize,
      passed: false,
    );
  }
}
