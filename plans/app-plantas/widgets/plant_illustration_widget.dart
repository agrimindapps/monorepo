// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

class PlantIllustrationWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color leafColor;
  final Color stemColor;
  final Color potColor;
  final Color soilColor;
  final PlantType plantType;
  final bool showShadow;

  const PlantIllustrationWidget({
    super.key,
    this.width = 200,
    this.height = 250,
    this.leafColor = const Color(0xFF4CAF50),
    this.stemColor = const Color(0xFF8BC34A),
    this.potColor = const Color(0xFF8D6E63),
    this.soilColor = const Color(0xFF5D4037),
    this.plantType = PlantType.leafy,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Shadow
          if (showShadow)
            Positioned(
              bottom: 0,
              left: width * 0.1,
              right: width * 0.1,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

          // Plant illustration
          Positioned.fill(
            child: CustomPaint(
              painter: PlantPainter(
                leafColor: leafColor,
                stemColor: stemColor,
                potColor: potColor,
                soilColor: soilColor,
                plantType: plantType,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum PlantType {
  leafy,
  succulent,
  flowering,
  tree,
  grass,
}

class PlantPainter extends CustomPainter {
  final Color leafColor;
  final Color stemColor;
  final Color potColor;
  final Color soilColor;
  final PlantType plantType;

  PlantPainter({
    required this.leafColor,
    required this.stemColor,
    required this.potColor,
    required this.soilColor,
    required this.plantType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Draw pot
    _drawPot(canvas, size, paint);

    // Draw soil
    _drawSoil(canvas, size, paint);

    // Draw plant based on type
    switch (plantType) {
      case PlantType.leafy:
        _drawLeafyPlant(canvas, size, paint);
        break;
      case PlantType.succulent:
        _drawSucculentPlant(canvas, size, paint);
        break;
      case PlantType.flowering:
        _drawFloweringPlant(canvas, size, paint);
        break;
      case PlantType.tree:
        _drawTreePlant(canvas, size, paint);
        break;
      case PlantType.grass:
        _drawGrassPlant(canvas, size, paint);
        break;
    }
  }

  void _drawPot(Canvas canvas, Size size, Paint paint) {
    paint.color = potColor;

    final potWidth = size.width * 0.6;
    final potHeight = size.height * 0.25;
    final potRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - potHeight / 2),
        width: potWidth,
        height: potHeight,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(potRect, paint);

    // Pot rim
    paint.color = potColor.withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height - potHeight + 8),
          width: potWidth + 8,
          height: 16,
        ),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  void _drawSoil(Canvas canvas, Size size, Paint paint) {
    paint.color = soilColor;

    final soilWidth = size.width * 0.5;
    final soilHeight = size.height * 0.08;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height - size.height * 0.21),
          width: soilWidth,
          height: soilHeight,
        ),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  void _drawLeafyPlant(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final soilY = size.height - size.height * 0.21;

    // Main stem
    paint.color = stemColor;
    paint.strokeWidth = 4;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX, soilY),
      Offset(centerX, soilY - size.height * 0.3),
      paint,
    );

    // Leaves
    paint.style = PaintingStyle.fill;
    paint.color = leafColor;

    // Left leaves
    _drawLeaf(
        canvas, Offset(centerX - 20, soilY - size.height * 0.15), -30, paint);
    _drawLeaf(
        canvas, Offset(centerX - 25, soilY - size.height * 0.25), -45, paint);

    // Right leaves
    _drawLeaf(
        canvas, Offset(centerX + 20, soilY - size.height * 0.12), 30, paint);
    _drawLeaf(
        canvas, Offset(centerX + 25, soilY - size.height * 0.22), 45, paint);

    // Top leaves
    _drawLeaf(
        canvas, Offset(centerX - 8, soilY - size.height * 0.28), -15, paint);
    _drawLeaf(
        canvas, Offset(centerX + 8, soilY - size.height * 0.28), 15, paint);
    _drawLeaf(canvas, Offset(centerX, soilY - size.height * 0.32), 0, paint);
  }

  void _drawSucculentPlant(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final soilY = size.height - size.height * 0.21;

    paint.color = leafColor;
    paint.style = PaintingStyle.fill;

    // Succulent layers
    for (int i = 0; i < 4; i++) {
      final layerY = soilY - (i * 15);
      final layerSize = 30 - (i * 3);

      // Draw multiple leaves in a circular pattern
      for (int j = 0; j < 8; j++) {
        final angle = (j * 45) * 3.14159 / 180;
        final leafX = centerX + (layerSize * 0.6) * math.cos(angle);
        final leafY = layerY + (layerSize * 0.6) * math.sin(angle);

        _drawSucculentLeaf(canvas, Offset(leafX, leafY), angle, paint);
      }
    }
  }

  void _drawFloweringPlant(Canvas canvas, Size size, Paint paint) {
    _drawLeafyPlant(canvas, size, paint); // Base plant

    // Add flowers
    final centerX = size.width / 2;
    final soilY = size.height - size.height * 0.21;

    paint.color = Colors.pink[300]!;

    // Flower positions
    final flowerPositions = [
      Offset(centerX - 15, soilY - size.height * 0.35),
      Offset(centerX + 12, soilY - size.height * 0.33),
      Offset(centerX - 5, soilY - size.height * 0.38),
    ];

    for (final pos in flowerPositions) {
      _drawFlower(canvas, pos, paint);
    }
  }

  void _drawTreePlant(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final soilY = size.height - size.height * 0.21;

    // Trunk
    paint.color = stemColor;
    paint.strokeWidth = 8;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX, soilY),
      Offset(centerX, soilY - size.height * 0.4),
      paint,
    );

    // Tree canopy
    paint.style = PaintingStyle.fill;
    paint.color = leafColor;
    canvas.drawCircle(
      Offset(centerX, soilY - size.height * 0.45),
      35,
      paint,
    );
  }

  void _drawGrassPlant(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final soilY = size.height - size.height * 0.21;

    paint.color = leafColor;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;

    // Multiple grass blades
    for (int i = -3; i <= 3; i++) {
      final bladeX = centerX + (i * 8);
      final bladeHeight = size.height * 0.25 + (i.abs() * -5);

      final path = Path();
      path.moveTo(bladeX, soilY);
      path.quadraticBezierTo(
        bladeX + (i * 2),
        soilY - bladeHeight * 0.7,
        bladeX + (i * 3),
        soilY - bladeHeight,
      );

      canvas.drawPath(path, paint);
    }
  }

  void _drawLeaf(Canvas canvas, Offset position, double angle, Paint paint) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle * 3.14159 / 180);

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(-8, -10, 0, -20);
    path.quadraticBezierTo(8, -10, 0, 0);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawSucculentLeaf(
      Canvas canvas, Offset position, double angle, Paint paint) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(-3, -8, 0, -15);
    path.quadraticBezierTo(3, -8, 0, 0);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawFlower(Canvas canvas, Offset position, Paint paint) {
    // Simple flower with 5 petals
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * 3.14159 / 180;
      final petalX = position.dx + 4 * math.cos(angle);
      final petalY = position.dy + 4 * math.sin(angle);

      canvas.drawCircle(Offset(petalX, petalY), 3, paint);
    }

    // Flower center
    paint.color = Colors.yellow[600]!;
    canvas.drawCircle(position, 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! PlantPainter ||
        oldDelegate.leafColor != leafColor ||
        oldDelegate.stemColor != stemColor ||
        oldDelegate.potColor != potColor ||
        oldDelegate.soilColor != soilColor ||
        oldDelegate.plantType != plantType;
  }
}
