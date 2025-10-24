import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/core/error/failures.dart';
import 'package:app_minigames/features/snake/domain/entities/enums.dart';
import 'package:app_minigames/features/snake/domain/entities/position.dart';
import 'package:app_minigames/features/snake/domain/usecases/update_snake_position_usecase.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late UpdateSnakePositionUseCase useCase;

  setUp(() {
    useCase = UpdateSnakePositionUseCase();
  });

  group('UpdateSnakePositionUseCase', () {
    test('should move snake forward successfully when running', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameStateMoving(
        direction: Direction.right,
        length: 3,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.snake.length, 3);
          expect(newState.head.x, gameState.head.x + 1);
          expect(newState.head.y, gameState.head.y);
        },
      );
    });

    test('should increase snake length when eating food', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameStateAboutToEat();

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.snake.length, gameState.snake.length + 1);
          expect(newState.score, gameState.score + 1);
          expect(newState.head, gameState.foodPosition);
        },
      );
    });

    test('should generate new food position after eating', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameStateAboutToEat();
      final oldFoodPosition = gameState.foodPosition;

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.foodPosition, isNot(equals(oldFoodPosition)));
          expect(newState.foodPosition.x, greaterThanOrEqualTo(0));
          expect(newState.foodPosition.y, greaterThanOrEqualTo(0));
          expect(newState.foodPosition.x, lessThan(newState.gridSize));
          expect(newState.foodPosition.y, lessThan(newState.gridSize));
        },
      );
    });

    test('should wrap around when moving beyond grid boundaries (right)', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        snake: [Position(19, 10)], // At right edge
        direction: Direction.right,
        gameStatus: SnakeGameStatus.running,
        gridSize: 20,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.head.x, 0); // Wrapped to left side
          expect(newState.head.y, 10);
        },
      );
    });

    test('should wrap around when moving beyond grid boundaries (left)', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        snake: [Position(0, 10)], // At left edge
        direction: Direction.left,
        gameStatus: SnakeGameStatus.running,
        gridSize: 20,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.head.x, 19); // Wrapped to right side
          expect(newState.head.y, 10);
        },
      );
    });

    test('should wrap around when moving beyond grid boundaries (up)', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        snake: [Position(10, 0)], // At top edge
        direction: Direction.up,
        gameStatus: SnakeGameStatus.running,
        gridSize: 20,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.head.x, 10);
          expect(newState.head.y, 19); // Wrapped to bottom
        },
      );
    });

    test('should wrap around when moving beyond grid boundaries (down)', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        snake: [Position(10, 19)], // At bottom edge
        direction: Direction.down,
        gameStatus: SnakeGameStatus.running,
        gridSize: 20,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.head.x, 10);
          expect(newState.head.y, 0); // Wrapped to top
        },
      );
    });

    test('should end game when colliding with own body', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        snake: [
          Position(10, 10), // head
          Position(9, 10),
          Position(9, 11),
          Position(10, 11), // This will cause collision
        ],
        direction: Direction.down,
        gameStatus: SnakeGameStatus.running,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.gameStatus, SnakeGameStatus.gameOver);
        },
      );
    });

    test('should return failure when game is not running', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        gameStatus: SnakeGameStatus.paused,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<GameLogicFailure>());
          expect(failure.message, 'Game is not running');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when game is not started', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        gameStatus: SnakeGameStatus.notStarted,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<GameLogicFailure>());
          expect(failure.message, 'Game is not running');
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should return failure when game is over', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        gameStatus: SnakeGameStatus.gameOver,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<GameLogicFailure>());
        },
        (_) => fail('Should not return success'),
      );
    });

    test('should not increase score when not eating food', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameStateMoving(
        direction: Direction.right,
      );
      final initialScore = gameState.score;

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.score, initialScore);
        },
      );
    });

    test('should maintain snake length when not eating food', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameStateMoving(
        direction: Direction.right,
        length: 5,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.snake.length, gameState.snake.length);
        },
      );
    });

    test('should move in correct direction - up', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        snake: [Position(10, 10)],
        direction: Direction.up,
        gameStatus: SnakeGameStatus.running,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.head.x, gameState.head.x);
          expect(newState.head.y, gameState.head.y - 1);
        },
      );
    });

    test('should move in correct direction - down', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        snake: [Position(10, 10)],
        direction: Direction.down,
        gameStatus: SnakeGameStatus.running,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.head.x, gameState.head.x);
          expect(newState.head.y, gameState.head.y + 1);
        },
      );
    });

    test('should move in correct direction - left', () async {
      // Arrange
      final gameState = TestFixtures.createSnakeGameState(
        snake: [Position(10, 10)],
        direction: Direction.left,
        gameStatus: SnakeGameStatus.running,
      );

      // Act
      final result = await useCase(currentState: gameState);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (newState) {
          expect(newState.head.x, gameState.head.x - 1);
          expect(newState.head.y, gameState.head.y);
        },
      );
    });
  });
}
