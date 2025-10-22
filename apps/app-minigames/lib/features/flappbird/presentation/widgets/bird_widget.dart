// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:math';

// Domain imports:
import '../../domain/entities/bird_entity.dart';

/// Widget to render the bird
class BirdWidget extends StatelessWidget {
  final BirdEntity bird;
  final double birdX;
  final double screenHeight;

  const BirdWidget({
    super.key,
    required this.bird,
    required this.birdX,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: birdX - bird.size / 2,
      top: bird.y - bird.size / 2,
      child: Transform.rotate(
        angle: bird.rotation,
        child: Container(
          width: bird.size,
          height: bird.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Eye
              Positioned(
                top: bird.size * 0.3,
                right: bird.size * 0.25,
                child: Container(
                  width: bird.size * 0.2,
                  height: bird.size * 0.2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Container(
                      width: bird.size * 0.1,
                      height: bird.size * 0.1,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              // Beak
              Positioned(
                top: bird.size * 0.45,
                right: bird.size * 0.05,
                child: Transform.rotate(
                  angle: -pi / 4,
                  child: Container(
                    width: bird.size * 0.2,
                    height: bird.size * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(bird.size * 0.05),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
