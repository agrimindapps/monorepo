// Flutter imports:
import 'package:flutter/material.dart';

/// Widget to render the game background (sky, clouds)
class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Sky blue
            Color(0xFFADD8E6), // Light blue
          ],
        ),
      ),
      child: const Stack(
        children: [
          // Static clouds
          Positioned(
            top: 50,
            left: 50,
            child: _CloudWidget(size: 60),
          ),
          Positioned(
            top: 100,
            right: 80,
            child: _CloudWidget(size: 80),
          ),
          Positioned(
            top: 180,
            left: 150,
            child: _CloudWidget(size: 50),
          ),
        ],
      ),
    );
  }
}

/// Simple cloud widget
class _CloudWidget extends StatelessWidget {
  final double size;

  const _CloudWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.5,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
}
