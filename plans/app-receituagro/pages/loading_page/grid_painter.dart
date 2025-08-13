// Flutter imports:
import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final bool isDark;
  final Color color;

  GridPainter({
    this.isDark = false,
    Color? color,
  }) : color = color ??
            (isDark
                ? Colors.green.shade900.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double space = 30;
    const double boldLineEvery = 5; // Linha mais grossa a cada 5 linhas

    // Linhas verticais
    for (double i = 0; i < size.width; i += space) {
      final bool isBoldLine = (i / space) % boldLineEvery == 0;
      paint.strokeWidth = isBoldLine ? 2 : 1;
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Linhas horizontais
    for (double i = 0; i < size.height; i += space) {
      final bool isBoldLine = (i / space) % boldLineEvery == 0;
      paint.strokeWidth = isBoldLine ? 2 : 1;
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      isDark != oldDelegate.isDark || color != oldDelegate.color;
}
