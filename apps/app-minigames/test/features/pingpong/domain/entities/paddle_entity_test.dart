import 'package:flutter_test/flutter_test.dart';
import 'package:app_minigames/features/pingpong/domain/entities/paddle_entity.dart';
import 'package:app_minigames/features/pingpong/domain/entities/ball_entity.dart';

void main() {
  group('PaddleEntity', () {
    test('should create player paddle on left', () {
      final paddle = PaddleEntity.player();

      expect(paddle.isLeft, true);
      expect(paddle.y, 0.5);
      expect(paddle.width, 15.0);
      expect(paddle.height, 100.0);
    });

    test('should create AI paddle on right', () {
      final paddle = PaddleEntity.ai();

      expect(paddle.isLeft, false);
      expect(paddle.y, 0.5);
    });

    test('should move paddle up within bounds', () {
      final paddle = PaddleEntity.player();
      final movedPaddle = paddle.moveUp(0.01);

      expect(movedPaddle.y, lessThan(paddle.y));
      expect(movedPaddle.y, greaterThanOrEqualTo(0.05));
    });

    test('should move paddle down within bounds', () {
      final paddle = PaddleEntity.player();
      final movedPaddle = paddle.moveDown(0.01);

      expect(movedPaddle.y, greaterThan(paddle.y));
      expect(movedPaddle.y, lessThanOrEqualTo(0.95));
    });

    test('should not move paddle beyond top boundary', () {
      const paddle = PaddleEntity(y: 0.06, isLeft: true);
      final movedPaddle = paddle.moveUp(0.1);

      expect(movedPaddle.y, greaterThanOrEqualTo(0.05));
    });

    test('should not move paddle beyond bottom boundary', () {
      const paddle = PaddleEntity(y: 0.94, isLeft: true);
      final movedPaddle = paddle.moveDown(0.1);

      expect(movedPaddle.y, lessThanOrEqualTo(0.95));
    });

    test('should detect collision with ball', () {
      const paddle = PaddleEntity(y: 0.5, isLeft: true);
      const ball = BallEntity(x: 0.06, y: 0.5);

      expect(paddle.collidesWith(ball), true);
    });

    test('should not detect collision when ball is far', () {
      const paddle = PaddleEntity(y: 0.5, isLeft: true);
      const ball = BallEntity(x: 0.3, y: 0.5);

      expect(paddle.collidesWith(ball), false);
    });

    test('should calculate hit position at center', () {
      const paddle = PaddleEntity(y: 0.5, isLeft: true);
      const ball = BallEntity(y: 0.5);

      final hitPosition = paddle.getHitPosition(ball);
      expect(hitPosition, closeTo(0.0, 0.01));
    });

    test('should calculate hit position at top', () {
      const paddle = PaddleEntity(y: 0.5, isLeft: true);
      const ball = BallEntity(y: 0.45);

      final hitPosition = paddle.getHitPosition(ball);
      expect(hitPosition, lessThan(0.0));
    });

    test('should calculate hit position at bottom', () {
      const paddle = PaddleEntity(y: 0.5, isLeft: true);
      const ball = BallEntity(y: 0.55);

      final hitPosition = paddle.getHitPosition(ball);
      expect(hitPosition, greaterThan(0.0));
    });
  });
}
