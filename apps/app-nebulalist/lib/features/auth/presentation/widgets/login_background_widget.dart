import 'dart:math';
import 'package:flutter/material.dart';

/// Widget responsible for the login page background with a Nebula theme
class LoginBackgroundWidget extends StatelessWidget {
  const LoginBackgroundWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2E1065), // Deep Purple
                  const Color(0xFF4C1D95), // Purple
                  const Color(0xFF1E1B4B), // Indigo
                ]
              : [
                  const Color(0xFF6D28D9), // Purple 600
                  const Color(0xFF7C3AED), // Purple 500
                  const Color(0xFF8B5CF6), // Purple 400
                ],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _NebulaPatternPainter(isDark: isDark),
            size: Size.infinite,
          ),
          child,
        ],
      ),
    );
  }
}

/// Painter to create a starry/nebula pattern
class _NebulaPatternPainter extends CustomPainter {
  _NebulaPatternPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent pattern

    // Draw "Stars"
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.15 : 0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2.5;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Draw "Nebula Clouds" (large faint circles)
    final cloudPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    for (int i = 0; i < 5; i++) {
      cloudPaint.color = (isDark ? Colors.pinkAccent : Colors.white)
          .withValues(alpha: isDark ? 0.05 : 0.1);
      
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 100.0 + random.nextDouble() * 150.0;
      
      canvas.drawCircle(Offset(x, y), radius, cloudPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
