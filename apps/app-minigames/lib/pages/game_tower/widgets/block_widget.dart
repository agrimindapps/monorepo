// Flutter imports:
import 'package:flutter/material.dart';

class BlockWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final bool isMoving;

  const BlockWidget({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    this.isMoving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 1.0),
            color.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: isMoving
          ? const Center(
              child: Text(
                'TAP!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
