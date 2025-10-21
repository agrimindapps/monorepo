// Flutter imports:
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  final List<ChartPoint> pontos;
  final double valorMaximo;
  final Color chartColor;
  final bool isDark;

  ChartPainter({
    required this.pontos,
    required this.valorMaximo,
    required this.chartColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: Implementar a lógica de pintura do gráfico
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChartPoint {
  final int periodo;
  final double valor;

  ChartPoint({
    required this.periodo,
    required this.valor,
  });
}
