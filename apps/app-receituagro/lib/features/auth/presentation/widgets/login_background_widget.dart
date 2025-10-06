import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget responsável pelo background da página de login do ReceitaAgro
/// Background estilizado com tema agrícola moderno e elementos visuais em camadas
class LoginBackgroundWidget extends StatelessWidget {
  final Widget child;

  const LoginBackgroundWidget({
    super.key,
    required this.child,
  });

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
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          colors: isDark
              ? [
                  const Color(0xFF0D2818), // Verde muito escuro base
                  const Color(0xFF1B3B2A), // Verde escuro médio
                  const Color(0xFF2D5A3D), // Verde médio com profundidade
                  const Color(0xFF1F4A32), // Verde escuro alternativo
                  const Color(0xFF0A1F12), // Verde quase preto final
                ]
              : [
                  const Color(0xFF81C784), // Verde claro suave no topo
                  const Color(0xFF66BB6A), // Verde médio-claro
                  const Color(0xFF4CAF50), // Verde principal (brand)
                  const Color(0xFF388E3C), // Verde médio-escuro
                  const Color(0xFF2E7D32), // Verde escuro na base
                ],
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  (isDark ? const Color(0xFF2D5A3D) : const Color(0xFF81C784))
                      .withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CustomPaint(
            painter: _ModernAgriculturalPatternPainter(isDark: isDark),
            size: Size.infinite,
          ),
          CustomPaint(
            painter: _GeometricFieldsPainter(isDark: isDark),
            size: Size.infinite,
          ),
          child,
        ],
      ),
    );
  }
}

/// Painter moderno para padrões agrícolas com mais sofisticação visual
class _ModernAgriculturalPatternPainter extends CustomPainter {
  final bool isDark;

  _ModernAgriculturalPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    _drawFieldRows(canvas, size);
    _drawIrrigationCircles(canvas, size);
    _drawOrganicElements(canvas, size);
  }

  /// Desenha fileiras de cultivo com perspectiva melhorada
  void _drawFieldRows(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark 
          ? const Color(0xFF81C784) 
          : const Color(0xFF2E7D32)).withValues(alpha: 0.04)
      ..strokeWidth = 0.8;
    const rowSpacing = 45.0;
    for (double i = 0; i <= size.width + 100; i += rowSpacing) {
      final startPoint = Offset(i, 0);
      final endPoint = Offset(i * 0.7, size.height);
      canvas.drawLine(startPoint, endPoint, paint);
      if (i % (rowSpacing * 2) == 0) {
        final secondaryPaint = Paint()
          ..color = paint.color.withValues(alpha: 0.02)
          ..strokeWidth = 1.2;
        
        canvas.drawLine(
          Offset(i + rowSpacing * 0.5, 0),
          Offset((i + rowSpacing * 0.5) * 0.7, size.height),
          secondaryPaint,
        );
      }
    }
  }

  /// Desenha círculos representando sistemas de irrigação moderna
  void _drawIrrigationCircles(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = (isDark 
          ? Colors.white.withValues(alpha: 0.02)
          : const Color(0xFF388E3C).withValues(alpha: 0.03))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = (isDark 
          ? const Color(0xFF66BB6A).withValues(alpha: 0.01)
          : const Color(0xFF4CAF50).withValues(alpha: 0.015))
      ..style = PaintingStyle.fill;
    const seed = 42; // Seed fixo para posições consistentes
    final random = math.Random(seed);
    
    for (int i = 0; i < 6; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final baseRadius = 30.0 + random.nextDouble() * 40;
      canvas.drawCircle(Offset(x, y), baseRadius, strokePaint);
      canvas.drawCircle(Offset(x, y), baseRadius * 0.7, fillPaint);
      canvas.drawCircle(
        Offset(x, y), 
        baseRadius * 0.4, 
        Paint()
          ..color = strokePaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }
  }

  /// Desenha elementos orgânicos estilizados (folhas, sementes, etc.)
  void _drawOrganicElements(Canvas canvas, Size size) {
    const seed = 123;
    final random = math.Random(seed);
    final seedPaint = Paint()
      ..color = (isDark 
          ? const Color(0xFFA5D6A7).withValues(alpha: 0.015)
          : const Color(0xFF66BB6A).withValues(alpha: 0.02))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.5 + random.nextDouble() * 2;
      
      canvas.drawCircle(Offset(x, y), radius, seedPaint);
    }
    final leafPaint = Paint()
      ..color = (isDark 
          ? const Color(0xFF81C784).withValues(alpha: 0.012)
          : const Color(0xFF388E3C).withValues(alpha: 0.02))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final rotation = random.nextDouble() * math.pi * 2;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      _drawStylizedLeaf(canvas, leafPaint);
      
      canvas.restore();
    }
  }

  void _drawStylizedLeaf(Canvas canvas, Paint paint) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(8, -12, 20, -8);
    path.quadraticBezierTo(25, -2, 22, 4);
    path.quadraticBezierTo(15, 8, 8, 6);
    path.quadraticBezierTo(3, 3, 0, 0);
    
    canvas.drawPath(path, paint);
    final nervurePaint = Paint()
      ..color = paint.color.withValues(alpha: paint.color.a * 1.5)
      ..strokeWidth = 0.3;
      
    canvas.drawLine(
      const Offset(0, 0),
      const Offset(18, -2),
      nervurePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para elementos geométricos modernos inspirados em agricultura de precisão
class _GeometricFieldsPainter extends CustomPainter {
  final bool isDark;

  _GeometricFieldsPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    _drawHexagonalGrid(canvas, size);
    _drawPrecisionPoints(canvas, size);
  }

  /// Grade hexagonal sutil (agricultura de precisão)
  void _drawHexagonalGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark 
          ? Colors.white.withValues(alpha: 0.008)
          : const Color(0xFF2E7D32).withValues(alpha: 0.015))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    const hexSize = 60.0;
    const hexWidth = hexSize * 2;
    final hexHeight = hexSize * math.sqrt(3);

    for (double row = 0; row < size.height + hexHeight; row += hexHeight * 0.75) {
      for (double col = 0; col < size.width + hexWidth; col += hexWidth * 0.75) {
        final offset = (row / (hexHeight * 0.75)).floor() % 2 == 1 
            ? hexWidth * 0.375 
            : 0.0;
        
        _drawHexagon(canvas, Offset(col + offset, row), hexSize, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Pontos de precisão representando dados de sensores
  void _drawPrecisionPoints(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark 
          ? const Color(0xFF4CAF50).withValues(alpha: 0.02)
          : const Color(0xFF1B5E20).withValues(alpha: 0.025))
      ..style = PaintingStyle.fill;

    const seed = 456;
    final random = math.Random(seed);
    
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
      canvas.drawCircle(
        Offset(x, y), 
        4, 
        Paint()
          ..color = paint.color.withValues(alpha: paint.color.a * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}