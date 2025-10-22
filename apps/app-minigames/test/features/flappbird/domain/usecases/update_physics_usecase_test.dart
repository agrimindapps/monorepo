// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Domain imports:
import 'package:app_minigames/features/flappbird/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/bird_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/enums.dart';
import 'package:app_minigames/features/flappbird/domain/usecases/update_physics_usecase.dart';

void main() {
  late UpdatePhysicsUseCase useCase;

  setUp(() {
    useCase = UpdatePhysicsUseCase();
  });

  group('UpdatePhysicsUseCase', () {
    test('should apply gravity to bird when game is playing', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: 800).copyWith(
          y: 400,
          velocity: 0,
        ),
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          // Velocity should increase by gravity
          expect(
            newState.bird.velocity,
            greaterThan(gameState.bird.velocity),
          );
          // Y position should increase (fall down)
          expect(newState.bird.y, greaterThan(gameState.bird.y));
          // Status should still be playing
          expect(newState.status, FlappyGameStatus.playing);
        },
      );
    });

    test('should set game over when bird hits ground', () async {
      // Arrange
      final screenHeight = 800.0;
      final groundHeight = screenHeight * 0.15;
      final playAreaHeight = screenHeight - groundHeight;

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: screenHeight).copyWith(
          y: playAreaHeight - 10, // Very close to ground
          velocity: 20, // Fast downward
        ),
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.status, FlappyGameStatus.gameOver);
        },
      );
    });

    test('should set game over when bird hits ceiling', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: 800).copyWith(
          y: 10, // Very close to ceiling
          velocity: -15, // Fast upward
        ),
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.status, FlappyGameStatus.gameOver);
        },
      );
    });

    test('should not update physics when game is not playing', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(
        status: FlappyGameStatus.ready,
        bird: BirdEntity.initial(screenHeight: 800).copyWith(
          y: 400,
          velocity: 0,
        ),
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          // Bird should not move
          expect(newState.bird.y, gameState.bird.y);
          expect(newState.bird.velocity, gameState.bird.velocity);
        },
      );
    });

    test('should update bird rotation based on velocity', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: 800).copyWith(
          y: 400,
          velocity: 5, // Falling
        ),
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          // Rotation should be positive (tilted down) when falling
          expect(newState.bird.rotation, greaterThan(0));
        },
      );
    });
  });
}
