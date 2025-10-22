// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Domain imports:
import 'package:app_minigames/features/flappbird/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/enums.dart';
import 'package:app_minigames/features/flappbird/domain/usecases/start_game_usecase.dart';

void main() {
  late StartGameUseCase useCase;

  setUp(() {
    useCase = StartGameUseCase();
  });

  group('StartGameUseCase', () {
    test('should initialize game with 2 pipes', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.pipes.length, 2);
          expect(newState.pipes[0].id, 'pipe_0');
          expect(newState.pipes[1].id, 'pipe_1');
        },
      );
    });

    test('should set game status to playing', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.status, FlappyGameStatus.playing);
        },
      );
    });

    test('should reset score to 0', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(score: 10); // Previous score

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.score, 0);
        },
      );
    });

    test('should reset bird velocity and rotation', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(
        bird: FlappyGameState.initial(
          screenWidth: 400,
          screenHeight: 800,
        ).bird.copyWith(
          velocity: 15,
          rotation: 1.2,
        ),
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.bird.velocity, 0.0);
          expect(newState.bird.rotation, 0.0);
        },
      );
    });

    test('should place pipes with proper spacing', () async {
      // Arrange
      final screenWidth = 400.0;
      final gameState = FlappyGameState.initial(
        screenWidth: screenWidth,
        screenHeight: 800,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          final pipe1X = newState.pipes[0].x;
          final pipe2X = newState.pipes[1].x;

          // First pipe should be at screenWidth + 100
          expect(pipe1X, screenWidth + 100);

          // Second pipe should be 300px away from first
          expect(pipe2X, pipe1X + 300);
        },
      );
    });

    test('should create pipes with random gap positions', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      );

      // Act - run multiple times to test randomness
      final results = <FlappyGameState>[];
      for (var i = 0; i < 5; i++) {
        final result = await useCase(currentState: gameState);
        result.fold(
          (failure) => fail('Should not return failure'),
          (newState) => results.add(newState),
        );
      }

      // Assert - at least some variation in pipe heights
      final topHeights = results.map((s) => s.pipes[0].topHeight).toSet();
      expect(topHeights.length, greaterThan(1)); // Should have some variation
    });

    test('should preserve screen dimensions and difficulty', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 500,
        screenHeight: 1000,
      ).copyWith(difficulty: FlappyDifficulty.hard);

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.screenWidth, 500);
          expect(newState.screenHeight, 1000);
          expect(newState.difficulty, FlappyDifficulty.hard);
        },
      );
    });
  });
}
