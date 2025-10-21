// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/models/game_logic.dart';

class ParallaxBackground extends StatelessWidget {
  final FlappyBirdLogic gameLogic;
  final Size screenSize;

  const ParallaxBackground({
    super.key,
    required this.gameLogic,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Clouds
        ...gameLogic.clouds.map((cloud) {
          return Positioned(
            top: cloud.y,
            left: screenSize.width * cloud.x,
            child: const RepaintBoundary(
              child: CloudWidget(),
            ),
          );
        }),

        // Bushes
        ...gameLogic.bushes.map((bush) {
          return Positioned(
            bottom: bush.y,
            left: screenSize.width * bush.x,
            child: const RepaintBoundary(
              child: BushWidget(),
            ),
          );
        }),
      ],
    );
  }
}

class CloudWidget extends StatelessWidget {
  const CloudWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class BushWidget extends StatelessWidget {
  const BushWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}
