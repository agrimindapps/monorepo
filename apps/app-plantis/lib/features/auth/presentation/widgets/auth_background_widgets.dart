import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// Modern background wrapper with plant-themed gradient and animated elements
///
/// Provides a decorative background for authentication screens with:
/// - Plant-themed gradient background
/// - Animated background pattern
/// - Floating plant elements
class ModernBackground extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final Color primaryColor;

  const ModernBackground({
    required this.child,
    required this.animation,
    required this.primaryColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            PlantisColors.primaryLight,
            const Color(0xFF2ECC71), // Fresh plant green
          ],
        ),
      ),
      child: Stack(
        children: [
          PlantBackgroundPattern(
            animation: animation,
            primaryColor: primaryColor,
          ),
          FloatingPlantElements(animation: animation),
          child,
        ],
      ),
    );
  }
}

/// Enhanced background pattern with plant motifs
///
/// Displays animated circles, curves, and dots that move subtly
/// to create an organic, living background effect.
class PlantBackgroundPattern extends StatelessWidget {
  final Animation<double> animation;
  final Color primaryColor;

  const PlantBackgroundPattern({
    required this.animation,
    required this.primaryColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: PlantBackgroundPatternPainter(
              animation: animation.value,
              primaryColor: primaryColor,
            ),
          ),
        );
      },
    );
  }
}

/// Floating plant elements with enhanced animations
///
/// Displays animated plant icons (eco, local_florist, grain) that
/// float, rotate, and scale to create a dynamic background effect.
class FloatingPlantElements extends StatelessWidget {
  final Animation<double> animation;

  const FloatingPlantElements({
    required this.animation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top right - Eco icon with rotation and translation
        Positioned(
          top: 80,
          right: 40,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: animation.value * 2 * math.pi * 0.5,
                child: Transform.translate(
                  offset: Offset(
                    10 * math.sin(animation.value * 2 * math.pi),
                    5 * math.cos(animation.value * 2 * math.pi),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Colors.white.withValues(alpha: 0.12),
                    size: 45,
                  ),
                ),
              );
            },
          ),
        ),
        // Bottom left - Flower icon with rotation and scale
        Positioned(
          bottom: 120,
          left: 30,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: -animation.value * 1.3 * math.pi,
                child: Transform.scale(
                  scale: 1.0 + (0.1 * math.sin(animation.value * 3 * math.pi)),
                  child: Icon(
                    Icons.local_florist,
                    color: Colors.white.withValues(alpha: 0.1),
                    size: 38,
                  ),
                ),
              );
            },
          ),
        ),
        // Top left - Grain icon with translation
        Positioned(
          top: 200,
          left: 60,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  15 * math.sin(animation.value * 1.5 * math.pi),
                  8 * math.cos(animation.value * 1.8 * math.pi),
                ),
                child: Icon(
                  Icons.grain,
                  color: Colors.white.withValues(alpha: 0.08),
                  size: 28,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Enhanced plant-themed background painter
///
/// Draws animated circles, curved paths, and dot patterns that move
/// subtly to create an organic background effect.
class PlantBackgroundPatternPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;

  PlantBackgroundPatternPainter({
    required this.animation,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw animated circles
    final basePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final x =
          (size.width * (i + 1) / 7) + (40 * math.sin(animation * 1.5 + i));
      final y =
          (size.height * (i + 1) / 8) + (25 * math.cos(animation * 1.2 + i));
      final radius = 15 + (8 * math.sin(animation * 2.5 + i));

      canvas.drawCircle(Offset(x, y), radius, basePaint);
    }

    // Draw curved paths (organic vine-like shapes)
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.04)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final startX = size.width * (i + 1) / 5;
      final startY = size.height * 0.2 + (100 * math.sin(animation + i));

      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + 30 + (20 * math.cos(animation * 0.8 + i)),
        startY + 40 + (15 * math.sin(animation * 0.6 + i)),
        startX + 10 + (25 * math.sin(animation * 0.5 + i)),
        startY + 80 + (20 * math.cos(animation * 0.7 + i)),
      );

      canvas.drawPath(path, linePaint);
    }

    // Draw animated dot pattern
    final dotPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < size.width; i += 60) {
      for (int j = 0; j < size.height; j += 60) {
        final offsetX = 10 * math.sin(animation * 0.3 + i * 0.01);
        final offsetY = 8 * math.cos(animation * 0.4 + j * 0.01);
        canvas.drawCircle(
          Offset(i.toDouble() + offsetX, j.toDouble() + offsetY),
          2.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PlantBackgroundPatternPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
