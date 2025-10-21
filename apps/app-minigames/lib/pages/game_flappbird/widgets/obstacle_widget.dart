// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/obstacle.dart';

class ObstacleWidget extends StatelessWidget {
  final Obstacle obstacle;

  const ObstacleWidget({
    super.key,
    required this.obstacle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Obstáculo superior
        Positioned(
          left: obstacle.x,
          top: 0,
          child: _buildObstaclePipe(obstacle.topHeight, true),
        ),

        // Obstáculo inferior
        Positioned(
          left: obstacle.x,
          bottom: 0,
          child: _buildObstaclePipe(obstacle.bottomHeight, false),
        ),
      ],
    );
  }

  Widget _buildObstaclePipe(double height, bool isTop) {
    return Column(
      children: [
        // Extremidade do cano (mais larga)
        Container(
          width: obstacle.width + 10,
          height: 20,
          decoration: BoxDecoration(
            color: GameColors.obstacle.withValues(alpha: 0.9),
            borderRadius: BorderRadius.vertical(
              top: isTop ? Radius.zero : const Radius.circular(8),
              bottom: isTop ? const Radius.circular(8) : Radius.zero,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: Offset(0, isTop ? 2 : -2),
              ),
            ],
          ),
        ),

        // Corpo do cano
        Container(
          width: obstacle.width,
          height: height - 20, // Subtrai a altura da extremidade
          color: GameColors.obstacle,
        ),
      ],
    );
  }
}
