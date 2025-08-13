import 'package:flutter/material.dart';

/// Widget responsável pelo background da página de login
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
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
                ]
              : [
                  Colors.blue.shade700,
                  Colors.blue.shade600,
                  Colors.blue.shade500,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          CustomPaint(
            painter: _BackgroundPatternPainter(isDark: isDark),
            size: Size.infinite,
          ),
          // Content
          child,
        ],
      ),
    );
  }
}

/// Painter para criar padrão de fundo
class _BackgroundPatternPainter extends CustomPainter {
  final bool isDark;

  _BackgroundPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final Color primaryColor = isDark
        ? Colors.amber.withValues(alpha: 0.03)
        : Colors.blue.shade700.withValues(alpha: 0.03);

    final Color secondaryColor = isDark
        ? Colors.amber.shade200.withValues(alpha: 0.02)
        : Colors.blue.shade200.withValues(alpha: 0.03);

    // Linhas diagonais
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.2;

    for (double i = 0; i <= size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), linePaint);
      canvas.drawLine(
          Offset(size.width - i, 0), Offset(size.width, i), linePaint);
    }

    // Pontos pequenos
    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < size.width; i += 50) {
      for (int j = 0; j < size.height; j += 50) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 2.5, dotPaint);
      }
    }

    // Círculos maiores
    final accentPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.blue.shade700.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 10; i++) {
      final x = ((random + i * 7919) % size.width.toInt()).toDouble();
      final y = ((random + i * 6029) % size.height.toInt()).toDouble();
      final radius = 20.0 + (random + i * 104729) % 60;

      canvas.drawCircle(Offset(x, y), radius, accentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}