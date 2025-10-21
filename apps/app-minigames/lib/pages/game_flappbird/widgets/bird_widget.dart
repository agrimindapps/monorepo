// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/bird.dart';

class BirdWidget extends StatelessWidget {
  final Bird bird;

  const BirdWidget({
    super.key,
    required this.bird,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationZ(bird.rotation),
      child: Container(
        width: bird.size,
        height: bird.size,
        decoration: BoxDecoration(
          color: GameColors.bird,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: VisualEffects.birdShadowBlur,
              offset: const Offset(
                VisualEffects.birdShadowOffsetX,
                VisualEffects.birdShadowOffsetY,
              ),
            ),
          ],
        ),
        child: Center(
          child: RepaintBoundary(
            child: Container(
              width: bird.size * Layout.birdEyeOuterSizeRatio,
              height: bird.size * Layout.birdEyeOuterSizeRatio,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: bird.size * Layout.birdPupilSizeRatio,
                  height: bird.size * Layout.birdPupilSizeRatio,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
