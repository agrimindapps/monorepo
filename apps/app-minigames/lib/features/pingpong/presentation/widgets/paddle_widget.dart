import 'package:flutter/material.dart';
import '../../domain/entities/paddle_entity.dart';

class PaddleWidget extends StatelessWidget {
  final PaddleEntity paddle;
  final double screenWidth;
  final double screenHeight;

  const PaddleWidget({
    super.key,
    required this.paddle,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final left = paddle.isLeft
        ? 20.0
        : screenWidth - paddle.width - 20.0;
    final top = (paddle.y * screenHeight) - (paddle.height / 2);

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: paddle.width,
        height: paddle.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.white24,
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
