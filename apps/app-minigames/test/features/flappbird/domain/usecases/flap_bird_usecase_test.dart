// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Core imports:
import 'package:core/core.dart';

// Domain imports:
import 'package:app_minigames/features/flappbird/domain/entities/game_state_entity.dart';
import 'package:app_minigames/features/flappbird/domain/entities/enums.dart';
import 'package:app_minigames/features/flappbird/domain/usecases/flap_bird_usecase.dart';

void main() {
  late FlapBirdUseCase useCase;

  setUp(() {
    useCase = FlapBirdUseCase();
  });

  group('FlapBirdUseCase', () {
    test('should apply jump velocity when game is playing', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(status: FlappyGameStatus.playing);

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.bird.velocity, FlapBirdUseCase.jumpStrength);
          expect(newState.bird.rotation, -0.4); // Tilted upward
        },
      );
    });

    test('should return ValidationFailure when game is not playing', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(status: FlappyGameStatus.ready);

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Cannot flap when game is not playing');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return ValidationFailure when game is over', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(status: FlappyGameStatus.gameOver);

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should not modify other game state properties', () async {
      // Arrange
      final gameState = FlappyGameState.initial(
        screenWidth: 400,
        screenHeight: 800,
      ).copyWith(
        status: FlappyGameStatus.playing,
        score: 5,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.score, 5);
          expect(newState.pipes, gameState.pipes);
          expect(newState.status, FlappyGameStatus.playing);
        },
      );
    });
  });
}
