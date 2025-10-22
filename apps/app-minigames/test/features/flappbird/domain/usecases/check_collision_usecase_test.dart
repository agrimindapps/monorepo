// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Domain imports:
import 'package:app_minigames/features/flappbird/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/bird_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/pipe_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/enums.dart';
import 'package:app_minigames/features/flappbird/domain/usecases/check_collision_usecase.dart';

void main() {
  late CheckCollisionUseCase useCase;

  setUp(() {
    useCase = CheckCollisionUseCase();
  });

  group('CheckCollisionUseCase', () {
    test('should detect collision with top pipe', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 100,
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: screenHeight).copyWith(
          y: 150, // Inside top pipe
        ),
        pipes: [pipe],
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

    test('should detect collision with bottom pipe', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 100,
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: screenHeight).copyWith(
          y: playAreaHeight - 50, // Inside bottom pipe
        ),
        pipes: [pipe],
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

    test('should not detect collision when bird is in gap', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 100,
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final gapCenterY = pipe.gapCenterY;

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: screenHeight).copyWith(
          y: gapCenterY, // In the center of gap
        ),
        pipes: [pipe],
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.status, FlappyGameStatus.playing); // Still playing
        },
      );
    });

    test('should not detect collision when bird is before pipe', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 200, // Pipe far to the right
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: screenHeight).copyWith(
          y: 150, // Would collide if pipe was here
        ),
        pipes: [pipe],
      );

      // Bird X is at 25% = 100px, pipe X is 200px
      expect(gameState.birdX, lessThan(pipe.x));

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.status, FlappyGameStatus.playing); // Still playing
        },
      );
    });

    test('should not check collision when game is not playing', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 100,
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.ready,
        bird: BirdEntity.initial(screenHeight: screenHeight).copyWith(
          y: 150, // Would collide if playing
        ),
        pipes: [pipe],
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.status, FlappyGameStatus.ready); // Status unchanged
        },
      );
    });

    test('should check collision with multiple pipes', () async {
      // Arrange
      final screenHeight = 800.0;
      final playAreaHeight = screenHeight * 0.85;

      final pipe1 = PipeEntity(
        id: 'pipe_1',
        x: 300, // Far right
        topHeight: 200,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final pipe2 = PipeEntity(
        id: 'pipe_2',
        x: 100, // Near bird
        topHeight: 150,
        screenHeight: playAreaHeight,
        gapSize: 0.25,
        width: 80,
      );

      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: screenHeight,
      ).copyWith(
        status: FlappyGameStatus.playing,
        bird: BirdEntity.initial(screenHeight: screenHeight).copyWith(
          y: 100, // Collides with pipe2
        ),
        pipes: [pipe1, pipe2],
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
  });
}
