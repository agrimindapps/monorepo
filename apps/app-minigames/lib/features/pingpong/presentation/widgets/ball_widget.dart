import 'package:flutter/material.dart';
import '../../domain/entities/ball_entity.dart';

class BallWidget extends StatelessWidget {
  final BallEntity ball;
  final double screenWidth;
  final double screenHeight;

  const BallWidget({
    super.key,
    required this.ball,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final left = (ball.x * screenWidth) - ball.radius;
    final top = (ball.y * screenHeight) - ball.radius;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: ball.radius * 2,
        height: ball.radius * 2,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white30,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
