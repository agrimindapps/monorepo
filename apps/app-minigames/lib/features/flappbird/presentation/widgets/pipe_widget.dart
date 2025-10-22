// Flutter imports:
import 'package:flutter/material.dart';

// Domain imports:
import '../../domain/entities/pipe_entity.dart';

/// Widget to render a pipe obstacle
class PipeWidget extends StatelessWidget {
  final PipeEntity pipe;
  final double screenWidth;
  final double screenHeight;

  const PipeWidget({
    super.key,
    required this.pipe,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top pipe
        Positioned(
          left: pipe.x,
          top: 0,
          child: Container(
            width: pipe.width,
            height: pipe.topHeight,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              border: Border.all(
                color: Colors.green.shade900,
                width: 3,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: CustomPaint(
              painter: _PipePatternPainter(),
            ),
          ),
        ),

        // Bottom pipe
        Positioned(
          left: pipe.x,
          bottom: 0,
          child: Container(
            width: pipe.width,
            height: pipe.bottomHeight,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              border: Border.all(
                color: Colors.green.shade900,
                width: 3,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: CustomPaint(
              painter: _PipePatternPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for pipe pattern (simple gradient effect)
class _PipePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade800.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Vertical stripes
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, 10, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
