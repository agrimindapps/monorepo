// Package imports:
import 'package:dartz/dartz.dart';
import 'dart:math';

// Core imports:
import 'package:core/core.dart';

// Entity imports:
import '../entities/game_state_entity.dart';
import '../entities/pipe_entity.dart';

/// Use case to update pipes (movement, scoring, spawning)
class UpdatePipesUseCase {
  /// Pipe spacing constant (pixels)
  static const double pipeSpacing = 300.0;

  /// Distance threshold to spawn new pipe
  static const double spawnDistance = 50.0;

  Future<Either<Failure, FlappyGameState>> call({
    required FlappyGameState currentState,
  }) async {
    try {
      // Only update pipes when playing
      if (!currentState.isPlaying) {
        return Right(currentState);
      }

      final gameSpeed = currentState.difficulty.gameSpeed;
      final birdX = currentState.birdX;
      int scoreIncrease = 0;

      // Move pipes and update passed status
      final updatedPipes = currentState.pipes.map((pipe) {
        var movedPipe = pipe.moveLeft(gameSpeed);

        // Check if bird just passed this pipe
        if (movedPipe.checkPassed(birdX)) {
          scoreIncrease++;
          movedPipe = movedPipe.markPassed();
        }

        return movedPipe;
      }).toList();

      // Remove off-screen pipes
      updatedPipes.removeWhere((pipe) => pipe.isOffScreen());

      // Spawn new pipe if needed
      if (updatedPipes.isEmpty ||
          updatedPipes.last.x < currentState.screenWidth - pipeSpacing + spawnDistance) {
        updatedPipes.add(_createNewPipe(currentState, updatedPipes.length));
      }

      return Right(
        currentState.copyWith(
          pipes: updatedPipes,
          score: currentState.score + scoreIncrease,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update pipes: $e'));
    }
  }

  /// Create a new pipe at the right edge of screen
  PipeEntity _createNewPipe(FlappyGameState state, int index) {
    final random = Random();

    // Min top height: 10% of screen
    final minTopHeight = state.playAreaHeight * 0.1;
    // Max top height: ensure gap fits
    final maxTopHeight = state.playAreaHeight * (1 - state.difficulty.gapSize) - minTopHeight;

    final topHeight = minTopHeight + random.nextDouble() * (maxTopHeight - minTopHeight);

    return PipeEntity(
      id: 'pipe_$index',
      x: state.screenWidth + 50,
      topHeight: topHeight,
      screenHeight: state.playAreaHeight,
      gapSize: state.difficulty.gapSize,
      passed: false,
    );
  }
}
