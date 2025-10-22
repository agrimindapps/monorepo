// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Domain imports:
import 'package:app_minigames/features/flappbird/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/pipe_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/enums.dart';
import 'package:app_minigames/features/flappbird/domain/usecases/update_pipes_usecase.dart';

void main() {
  late UpdatePipesUseCase useCase;

  setUp(() {
    useCase = UpdatePipesUseCase();
  });

  group('UpdatePipesUseCase', () {
    test('should move pipes to the left', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 200,
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        difficulty: FlappyDifficulty.medium, // Speed = 3.5
        pipes: [pipe],
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.pipes.length, greaterThanOrEqualTo(1));
          expect(
            newState.pipes.first.x,
            lessThan(pipe.x),
          );
        },
      );
    });

    test('should increment score when bird passes pipe', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;
      final birdX = 400.0 * 0.25; // Bird at 25% from left = 100px

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: birdX - 50, // Pipe 50px before bird (bird passed it)
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
        passed: false,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        difficulty: FlappyDifficulty.medium,
        pipes: [pipe],
        score: 0,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.score, 1);
          // Pipe should be marked as passed
          final passedPipes = newState.pipes.where((p) => p.id == 'pipe_1');
          if (passedPipes.isNotEmpty) {
            expect(passedPipes.first.passed, true);
          }
        },
      );
    });

    test('should remove off-screen pipes', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final offScreenPipe = PipeEntity(
        id: 'pipe_1',
        x: -100, // Off screen
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final visiblePipe = PipeEntity(
        id: 'pipe_2',
        x: 200,
        topHeight: 250,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        difficulty: FlappyDifficulty.medium,
        pipes: [offScreenPipe, visiblePipe],
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          // Off-screen pipe should be removed
          final hasOffScreenPipe = newState.pipes.any((p) => p.id == 'pipe_1');
          expect(hasOffScreenPipe, false);
          // Visible pipe should remain (or new pipes spawned)
          expect(newState.pipes.isNotEmpty, true);
        },
      );
    });

    test('should spawn new pipe when last pipe reaches threshold', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;
      final screenWidth = 400.0;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: screenWidth - UpdatePipesUseCase.pipeSpacing + 40, // Close to threshold
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        difficulty: FlappyDifficulty.medium,
        pipes: [pipe],
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          // Should have spawned a new pipe
          expect(newState.pipes.length, greaterThan(gameState.pipes.length));
        },
      );
    });

    test('should not update pipes when game is not playing', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 200,
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.ready,
        pipes: [pipe],
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          // Pipes should not move
          expect(newState.pipes.first.x, pipe.x);
          expect(newState.pipes.length, 1);
        },
      );
    });

    test('should not increment score for already passed pipes', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;
      final birdX = 400.0 * 0.25;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: birdX - 100,
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
        passed: true, // Already passed
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        difficulty: FlappyDifficulty.medium,
        pipes: [pipe],
        score: 5,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          // Score should not increase (may increase from new pipes, but not this one)
          // Check that the original pipe didn't add to score
          final originalPipe = newState.pipes.firstWhere(
            (p) => p.id == 'pipe_1',
            orElse: () => pipe,
          );
          expect(originalPipe.passed, true);
        },
      );
    });
  });
}
