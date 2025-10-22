import 'dart:math';
import 'package:flutter/material.dart';

/// Widget representing a single cloud
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

/// Animated background widget with floating clouds
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

    // Generate random clouds
    for (int i = 0; i < 10; i++) {
      _clouds.add({
        'size': _random.nextDouble() * 100 + 50, // Size between 50 and 150
        'top': _random.nextDouble(), // Relative vertical position
        'speed': _random.nextDouble() * 0.2 + 0.05, // Movement speed
        'delay': _random.nextDouble(), // Initial animation delay
        'opacity':
            _random.nextDouble() * 0.5 + 0.3, // Opacity between 0.3 and 0.8
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
                // Transparent sky background
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  color: Colors.transparent,
                ),

                // Animated clouds
                ..._clouds.map((cloud) {
                  // Calculate initial x position
                  final startPosition = -cloud['size'] as double;
                  final endPosition = constraints.maxWidth;
                  final totalDistance = endPosition - startPosition;

                  // Calculate current position based on animation
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
