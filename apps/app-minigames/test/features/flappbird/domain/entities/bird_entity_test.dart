// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

// Domain imports:
import 'package:app_minigames/features/flappbird/domain/entities/bird_entity.dart';

void main() {
  group('BirdEntity', () {
    test('should create initial bird at screen center', () {
      // Arrange
      const screenHeight = 800.0;

      // Act
      final bird = BirdEntity.initial(screenHeight: screenHeight);

      // Assert
      expect(bird.y, 400); // 50% of 800
      expect(bird.velocity, 0.0);
      expect(bird.rotation, 0.0);
      expect(bird.size, 50.0);
    });

    test('should apply gravity and update position', () {
      // Arrange
      final bird = BirdEntity.initial(screenHeight: 800);

      // Act
      final newBird = bird.applyGravity(0.6);

      // Assert
      expect(newBird.velocity, greaterThan(bird.velocity));
      expect(newBird.y, greaterThan(bird.y));
      expect(newBird.rotation, greaterThan(0)); // Tilted down
    });

    test('should apply flap with negative velocity', () {
      // Arrange
      final bird = BirdEntity.initial(screenHeight: 800).copyWith(
        velocity: 5, // Falling
      );

      // Act
      final newBird = bird.flap(-10.0);

      // Assert
      expect(newBird.velocity, -10.0);
      expect(newBird.rotation, -0.4); // Tilted up
    });

    test('should detect ground collision', () {
      // Arrange
      final bird = BirdEntity.initial(screenHeight: 800).copyWith(
        y: 680, // Close to ground
        size: 50,
      );

      // Act
      final isColliding = bird.isCollidingWithGround(680);

      // Assert
      expect(isColliding, true);
    });

    test('should detect ceiling collision', () {
      // Arrange
      final bird = BirdEntity.initial(screenHeight: 800).copyWith(
        y: 20, // Close to ceiling
        size: 50,
      );

      // Act
      final isColliding = bird.isCollidingWithCeiling();

      // Assert
      expect(isColliding, true);
    });

    test('should update rotation based on velocity direction', () {
      // Arrange
      final fallingBird = BirdEntity.initial(screenHeight: 800);

      // Act - falling (positive velocity)
      final falling = fallingBird.applyGravity(5.0);

      // Assert
      expect(falling.rotation, greaterThan(0)); // Tilted down

      // Act - jumping (negative velocity)
      final jumping = fallingBird.flap(-10.0);

      // Assert
      expect(jumping.rotation, lessThan(0)); // Tilted up
    });
  });
}
