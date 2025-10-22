import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/features/pingpong/domain/entities/ball_entity.dart';

void main() {
  group('BallEntity', () {
    test('should create ball with default values', () {
      const ball = BallEntity();

      expect(ball.x, 0.5);
      expect(ball.y, 0.5);
      expect(ball.velocityX, 0.005);
      expect(ball.velocityY, 0.0);
      expect(ball.radius, 10.0);
    });

    test('should move ball based on velocity', () {
      const ball = BallEntity(x: 0.5, y: 0.5, velocityX: 0.01, velocityY: 0.005);
      final movedBall = ball.move();

      expect(movedBall.x, 0.51);
      expect(movedBall.y, 0.505);
      expect(movedBall.velocityX, 0.01);
      expect(movedBall.velocityY, 0.005);
    });

    test('should bounce vertically by reversing Y velocity', () {
      const ball = BallEntity(velocityY: 0.005);
      final bouncedBall = ball.bounceVertical();

      expect(bouncedBall.velocityX, ball.velocityX);
      expect(bouncedBall.velocityY, -0.005);
    });

    test('should bounce horizontally with speed increase', () {
      const ball = BallEntity(velocityX: 0.005, velocityY: 0.003);
      final bouncedBall = ball.bounceHorizontal(speedIncrease: 1.1);

      expect(bouncedBall.velocityX, closeTo(-0.0055, 0.0001));
      expect(bouncedBall.velocityY, closeTo(0.0033, 0.0001));
    });

    test('should set angle based on hit position', () {
      const ball = BallEntity(velocityY: 0.002);
      final angledBall = ball.setAngle(0.5);

      expect(angledBall.velocityY, 0.004);
    });

    test('should reset ball to center with random velocity', () {
      const ball = BallEntity(x: 0.8, y: 0.7);
      final resetBall = ball.reset(toLeft: true);

      expect(resetBall.x, 0.5);
      expect(resetBall.y, 0.5);
      expect(resetBall.velocityX, -0.005);
    });

    test('should cap ball speed when exceeding maximum', () {
      const ball = BallEntity(velocityX: 0.02, velocityY: 0.015);
      final cappedBall = ball.capSpeed(maxSpeed: 0.015);

      expect(cappedBall.speed, lessThanOrEqualTo(0.015));
    });

    test('should not modify speed when below maximum', () {
      const ball = BallEntity(velocityX: 0.005, velocityY: 0.003);
      final cappedBall = ball.capSpeed(maxSpeed: 0.015);

      expect(cappedBall.velocityX, 0.005);
      expect(cappedBall.velocityY, 0.003);
    });

    test('should correctly identify ball direction', () {
      const ballLeft = BallEntity(velocityX: -0.005);
      const ballRight = BallEntity(velocityX: 0.005);

      expect(ballLeft.isMovingLeft, true);
      expect(ballLeft.isMovingRight, false);
      expect(ballRight.isMovingLeft, false);
      expect(ballRight.isMovingRight, true);
    });
  });
}
