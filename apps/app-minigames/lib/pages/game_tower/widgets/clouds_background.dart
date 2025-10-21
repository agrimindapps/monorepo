// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

class CloudWidget extends StatelessWidget {
  final double size;
  final double opacity;

  const CloudWidget({
    super.key,
    required this.size,
    this.opacity = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(size * 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class CloudsBackgroundWidget extends StatefulWidget {
  const CloudsBackgroundWidget({super.key});

  @override
  State<CloudsBackgroundWidget> createState() => _CloudsBackgroundWidgetState();
}

class _CloudsBackgroundWidgetState extends State<CloudsBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Map<String, dynamic>> _clouds = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 2),
    )..repeat(reverse: false);

    // Gerar nuvens aleatórias
    for (int i = 0; i < 10; i++) {
      _clouds.add({
        'size': _random.nextDouble() * 100 + 50, // Tamanho entre 50 e 150
        'top': _random.nextDouble(), // Posição vertical relativa à tela
        'speed': _random.nextDouble() * 0.2 + 0.05, // Velocidade de movimento
        'delay': _random.nextDouble(), // Atraso inicial na animação
        'opacity':
            _random.nextDouble() * 0.5 + 0.3, // Opacidade entre 0.3 e 0.8
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Céu de fundo
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Colors.transparent,
                ),

                // Nuvens animadas
                ..._clouds.map((cloud) {
                  // Calculamos a posição x inicial
                  final startPosition = -cloud['size'] as double;
                  final endPosition = constraints.maxWidth;
                  final totalDistance = endPosition - startPosition;

                  // Calculamos a posição atual baseada na animação
                  final adjustedTime =
                      (_controller.value + cloud['delay']) % 1.0;
                  final xPosition = startPosition +
                      (totalDistance * (adjustedTime / cloud['speed'])) %
                          (totalDistance * (1 + 1 / cloud['speed']));

                  return Positioned(
                    left: xPosition,
                    top: cloud['top'] * constraints.maxHeight,
                    child: CloudWidget(
                      size: cloud['size'],
                      opacity: cloud['opacity'],
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}
