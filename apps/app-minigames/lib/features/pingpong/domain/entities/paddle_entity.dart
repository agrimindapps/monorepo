import 'package:equatable/equatable.dart';
import 'ball_entity.dart';

class PaddleEntity extends Equatable {
  final double y;
  final double width;
  final double height;
  final bool isLeft;

  const PaddleEntity({
    this.y = 0.5,
    this.width = 15.0,
    this.height = 100.0,
    required this.isLeft,
  });

  factory PaddleEntity.player() => const PaddleEntity(isLeft: true);
  factory PaddleEntity.ai() => const PaddleEntity(isLeft: false);

  PaddleEntity moveUp(double speed) => copyWith(
        y: (y - speed).clamp(height / 2 / 1000, 1.0 - height / 2 / 1000),
      );

  PaddleEntity moveDown(double speed) => copyWith(
        y: (y + speed).clamp(height / 2 / 1000, 1.0 - height / 2 / 1000),
      );

  PaddleEntity moveTo(double targetY) => copyWith(
        y: targetY.clamp(height / 2 / 1000, 1.0 - height / 2 / 1000),
      );

  bool collidesWith(BallEntity ball) {
    final paddleX = isLeft ? 0.05 : 0.95;
    final paddleTop = y - height / 2 / 1000;
    final paddleBottom = y + height / 2 / 1000;

    final ballRadius = ball.radius / 1000;
    final ballLeft = ball.x - ballRadius;
    final ballRight = ball.x + ballRadius;
    final ballTop = ball.y - ballRadius;
    final ballBottom = ball.y + ballRadius;

    final paddleWidthNorm = width / 1000;
    final horizontalOverlap = isLeft
        ? (ballLeft <= paddleX + paddleWidthNorm && ballRight >= paddleX)
        : (ballRight >= paddleX - paddleWidthNorm && ballLeft <= paddleX);

    final verticalOverlap = ballBottom >= paddleTop && ballTop <= paddleBottom;

    return horizontalOverlap && verticalOverlap;
  }

  double getHitPosition(BallEntity ball) {
    final relativeY = (ball.y - y) / (height / 2 / 1000);
    return relativeY.clamp(-1.0, 1.0);
  }

  PaddleEntity copyWith({
    double? y,
    double? width,
    double? height,
    bool? isLeft,
  }) {
    return PaddleEntity(
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      isLeft: isLeft ?? this.isLeft,
    );
  }

  @override
  List<Object?> get props => [y, width, height, isLeft];

  @override
  String toString() =>
      'PaddleEntity(${isLeft ? "Player" : "AI"}, y: ${y.toStringAsFixed(3)})';
}
