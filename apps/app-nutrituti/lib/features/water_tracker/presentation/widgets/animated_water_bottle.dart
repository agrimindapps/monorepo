import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated water bottle widget showing hydration progress
class AnimatedWaterBottle extends StatefulWidget {
  final double progress; // 0.0 to 1.0+
  final int currentMl;
  final int goalMl;
  final VoidCallback? onTap;
  final double size;

  const AnimatedWaterBottle({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    this.onTap,
    this.size = 200,
  });

  @override
  State<AnimatedWaterBottle> createState() => _AnimatedWaterBottleState();
}

class _AnimatedWaterBottleState extends State<AnimatedWaterBottle>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fillAnimation = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0, 1),
    ).animate(CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeOutCubic,
    ));

    _fillController.forward();
  }

  @override
  void didUpdateWidget(AnimatedWaterBottle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _fillAnimation.value;
      _fillAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress.clamp(0, 1),
      ).animate(CurvedAnimation(
        parent: _fillController,
        curve: Curves.easeOutCubic,
      ));
      _fillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  Color _getWaterColor(double progress) {
    if (progress < 0.5) {
      // Red to yellow
      return Color.lerp(
        const Color(0xFFE57373),
        const Color(0xFFFFD54F),
        progress * 2,
      )!;
    } else if (progress < 0.8) {
      // Yellow to blue
      return Color.lerp(
        const Color(0xFFFFD54F),
        const Color(0xFF4FC3F7),
        (progress - 0.5) / 0.3,
      )!;
    } else {
      // Blue (healthy)
      return const Color(0xFF4FC3F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_waveController, _fillController]),
        builder: (context, child) {
          final fill = _fillAnimation.value;
          final waterColor = _getWaterColor(fill);

          return SizedBox(
            width: widget.size,
            height: widget.size * 1.3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bottle shape with water
                CustomPaint(
                  size: Size(widget.size, widget.size * 1.3),
                  painter: _BottlePainter(
                    fillLevel: fill,
                    wavePhase: _waveController.value,
                    waterColor: waterColor,
                  ),
                ),
                // Progress text
                Positioned(
                  bottom: widget.size * 0.4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.currentMl}',
                        style: TextStyle(
                          fontSize: widget.size * 0.18,
                          fontWeight: FontWeight.bold,
                          color: fill > 0.5 ? Colors.white : Colors.grey[800],
                          shadows: fill > 0.5
                              ? [
                                  const Shadow(
                                    blurRadius: 2,
                                    color: Colors.black26,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      Text(
                        'ml',
                        style: TextStyle(
                          fontSize: widget.size * 0.08,
                          color: fill > 0.5
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Goal indicator
                Positioned(
                  bottom: widget.size * 0.1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Meta: ${widget.goalMl}ml',
                      style: TextStyle(
                        fontSize: widget.size * 0.06,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Percentage badge
                Positioned(
                  top: widget.size * 0.05,
                  right: widget.size * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: waterColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: waterColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      '${(fill * 100).round()}%',
                      style: TextStyle(
                        fontSize: widget.size * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final double fillLevel;
  final double wavePhase;
  final Color waterColor;

  _BottlePainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bottleWidth = size.width * 0.6;
    final bottleHeight = size.height * 0.85;
    final neckWidth = size.width * 0.3;
    final neckHeight = size.height * 0.15;

    final centerX = size.width / 2;
    final bottleTop = neckHeight;
    final bottleBottom = size.height;

    // Bottle outline path
    final bottlePath = Path();

    // Neck
    bottlePath.moveTo(centerX - neckWidth / 2, 0);
    bottlePath.lineTo(centerX - neckWidth / 2, neckHeight * 0.6);

    // Left shoulder curve
    bottlePath.quadraticBezierTo(
      centerX - neckWidth / 2,
      bottleTop,
      centerX - bottleWidth / 2,
      bottleTop + size.height * 0.05,
    );

    // Left side
    bottlePath.lineTo(centerX - bottleWidth / 2, bottleBottom - 20);

    // Bottom left curve
    bottlePath.quadraticBezierTo(
      centerX - bottleWidth / 2,
      bottleBottom,
      centerX - bottleWidth / 2 + 20,
      bottleBottom,
    );

    // Bottom
    bottlePath.lineTo(centerX + bottleWidth / 2 - 20, bottleBottom);

    // Bottom right curve
    bottlePath.quadraticBezierTo(
      centerX + bottleWidth / 2,
      bottleBottom,
      centerX + bottleWidth / 2,
      bottleBottom - 20,
    );

    // Right side
    bottlePath.lineTo(centerX + bottleWidth / 2, bottleTop + size.height * 0.05);

    // Right shoulder curve
    bottlePath.quadraticBezierTo(
      centerX + neckWidth / 2,
      bottleTop,
      centerX + neckWidth / 2,
      neckHeight * 0.6,
    );

    // Neck right side
    bottlePath.lineTo(centerX + neckWidth / 2, 0);

    bottlePath.close();

    // Draw bottle glass effect
    final glassPaint = Paint()
      ..color = Colors.grey[300]!.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(bottlePath, glassPaint);

    // Draw water
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(bottlePath);

      final waterHeight = bottleHeight * fillLevel;
      final waterTop = bottleBottom - waterHeight;

      // Wave effect
      final wavePath = Path();
      wavePath.moveTo(0, bottleBottom);
      wavePath.lineTo(0, waterTop);

      for (double x = 0; x <= size.width; x += 1) {
        final wave1 = math.sin((x / size.width * 2 * math.pi) + (wavePhase * 2 * math.pi)) * 4;
        final wave2 = math.sin((x / size.width * 4 * math.pi) + (wavePhase * 2 * math.pi)) * 2;
        wavePath.lineTo(x, waterTop + wave1 + wave2);
      }

      wavePath.lineTo(size.width, bottleBottom);
      wavePath.close();

      // Water gradient
      final waterGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          waterColor.withValues(alpha: 0.8),
          waterColor,
        ],
      );

      final waterPaint = Paint()
        ..shader = waterGradient.createShader(
          Rect.fromLTRB(0, waterTop, size.width, bottleBottom),
        );

      canvas.drawPath(wavePath, waterPaint);
      canvas.restore();
    }

    // Draw bottle outline
    final outlinePaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(bottlePath, outlinePaint);

    // Glass shine effect
    final shinePath = Path();
    shinePath.moveTo(centerX - bottleWidth / 2 + 8, bottleTop + 20);
    shinePath.quadraticBezierTo(
      centerX - bottleWidth / 2 + 8,
      bottleBottom - 40,
      centerX - bottleWidth / 2 + 15,
      bottleBottom - 30,
    );

    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(_BottlePainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.waterColor != waterColor;
  }
}
