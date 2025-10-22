// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Domain imports:
import 'package:app_minigames/features/flappbird/domain/entities/pipe_entity.dart';

void main() {
  group('PipeEntity', () {
    test('should calculate bottom pipe height correctly', () {
      // Arrange
      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 200,
        topHeight: 200,
        screenHeight: 680,
        gapSize: 0.25,
      );

      // Act
      final bottomHeight = pipe.bottomHeight;

      // Assert
      // Bottom = screenHeight - topHeight - (screenHeight * gapSize)
      // Bottom = 680 - 200 - (680 * 0.25) = 680 - 200 - 170 = 310
      expect(bottomHeight, 310);
    });

    test('should calculate gap center Y position', () {
      // Arrange
      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 200,
        topHeight: 200,
        screenHeight: 680,
        gapSize: 0.25,
      );

      // Act
      final gapCenterY = pipe.gapCenterY;

      // Assert
      // Gap center = topHeight + (screenHeight * gapSize) / 2
      // Gap center = 200 + (680 * 0.25) / 2 = 200 + 85 = 285
      expect(gapCenterY, 285);
    });

    test('should move pipe to the left', () {
      // Arrange
      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 200,
        topHeight: 200,
        screenHeight: 680,
        gapSize: 0.25,
      );

      // Act
      final movedPipe = pipe.moveLeft(5.0);

      // Assert
      expect(movedPipe.x, 195);
    });

    test('should detect when pipe is off-screen', () {
      // Arrange
      final pipe = PipeEntity(
        id: 'pipe_1',
        x: -100,
        topHeight: 200,
        screenHeight: 680,
        gapSize: 0.25,
        width: 80,
      );

      // Act
      final isOffScreen = pipe.isOffScreen();

      // Assert
      expect(isOffScreen, true);
    });

    test('should check if bird passed pipe', () {
      // Arrange
      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 100,
        topHeight: 200,
        screenHeight: 680,
        gapSize: 0.25,
        width: 80,
        passed: false,
      );

      // Act
      final hasPassed = pipe.checkPassed(200); // Bird at x=200

      // Assert
      expect(hasPassed, true); // Bird passed pipe (200 > 100 + 80)
    });

    test('should not mark as passed if already passed', () {
      // Arrange
      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 100,
        topHeight: 200,
        screenHeight: 680,
        gapSize: 0.25,
        width: 80,
        passed: true, // Already passed
      );

      // Act
      final hasPassed = pipe.checkPassed(200);

      // Assert
      expect(hasPassed, false); // Should not count again
    });

    test('should detect collision with top pipe', () {
      // Arrange
      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 100,
        topHeight: 200,
        screenHeight: 680,
        gapSize: 0.25,
        width: 80,
      );

      // Act
      final hasCollision = pipe.checkCollision(140, 150, 50); // Bird in top pipe

      // Assert
      expect(hasCollision, true);
    });

    test('should not detect collision when bird is in gap', () {
      // Arrange
      final pipe = PipeEntity(
        id: 'pipe_1',
        x: 100,
        topHeight: 200,
        screenHeight: 680,
        gapSize: 0.25,
        width: 80,
      );

      final gapCenterY = pipe.gapCenterY;

      // Act
      final hasCollision = pipe.checkCollision(140, gapCenterY, 50); // Bird in gap

      // Assert
      expect(hasCollision, false);
    });
  });
}
