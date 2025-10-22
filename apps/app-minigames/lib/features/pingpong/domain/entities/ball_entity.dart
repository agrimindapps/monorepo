import 'dart:math';
import 'package:equatable/equatable.dart';

class BallEntity extends Equatable {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final double radius;

  const BallEntity({
    this.x = 0.5,
    this.y = 0.5,
    this.velocityX = 0.005,
    this.velocityY = 0.0,
    this.radius = 10.0,
  });

  factory BallEntity.initial() {
    final random = Random();
    return BallEntity(
      x: 0.5,
      y: 0.5,
      velocityX: random.nextBool() ? 0.005 : -0.005,
      velocityY: (random.nextDouble() * 0.004) - 0.002,
      radius: 10.0,
    );
  }

  BallEntity move() => copyWith(
        x: x + velocityX,
        y: y + velocityY,
      );

  BallEntity bounceVertical() => copyWith(velocityY: -velocityY);

  BallEntity bounceHorizontal({double speedIncrease = 1.05}) => copyWith(
        velocityX: -velocityX * speedIncrease,
        velocityY: velocityY * speedIncrease,
      );

  BallEntity setAngle(double hitPosition) {
    final maxAngle = 0.008;
    final newVelocityY = hitPosition * maxAngle;
    return copyWith(velocityY: newVelocityY);
  }

  BallEntity reset({required bool toLeft}) {
    final random = Random();
    return BallEntity(
      x: 0.5,
      y: 0.5,
      velocityX: toLeft ? -0.005 : 0.005,
      velocityY: (random.nextDouble() * 0.004) - 0.002,
      radius: radius,
    );
  }

  bool get isMovingLeft => velocityX < 0;
  bool get isMovingRight => velocityX > 0;

  double get speed => sqrt(velocityX * velocityX + velocityY * velocityY);

  BallEntity capSpeed({double maxSpeed = 0.015}) {
    final currentSpeed = speed;
    if (currentSpeed <= maxSpeed) return this;

    final ratio = maxSpeed / currentSpeed;
    return copyWith(
      velocityX: velocityX * ratio,
      velocityY: velocityY * ratio,
    );
  }

  BallEntity copyWith({
    double? x,
    double? y,
    double? velocityX,
    double? velocityY,
    double? radius,
  }) {
    return BallEntity(
      x: x ?? this.x,
      y: y ?? this.y,
      velocityX: velocityX ?? this.velocityX,
      velocityY: velocityY ?? this.velocityY,
      radius: radius ?? this.radius,
    );
  }

  @override
  List<Object?> get props => [x, y, velocityX, velocityY, radius];

  @override
  String toString() =>
      'BallEntity(x: ${x.toStringAsFixed(3)}, y: ${y.toStringAsFixed(3)}, vx: ${velocityX.toStringAsFixed(4)}, vy: ${velocityY.toStringAsFixed(4)})';
}
