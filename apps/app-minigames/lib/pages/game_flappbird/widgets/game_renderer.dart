// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';
import 'bird_widget.dart';
import 'game_overlay.dart';
import 'obstacle_widget.dart';
import 'parallax_background.dart';
import 'score_display.dart';

class GameRenderer extends StatelessWidget {
  final FlappyBirdLogic gameLogic;
  final Animation<double>? flapAnimation;
  final AnimationController? flapController;
  final bool isPaused;

  const GameRenderer({
    super.key,
    required this.gameLogic,
    this.flapAnimation,
    this.flapController,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: GameColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Parallax Background
          ParallaxBackground(
            gameLogic: gameLogic,
            screenSize: size,
          ),

          // Obstacles
          ...gameLogic.obstacles
              .map((obstacle) => ObstacleWidget(obstacle: obstacle)),

          // Ground
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: gameLogic.groundHeight,
            child: Container(
              color: GameColors.ground,
              child: Center(
                child: SizedBox(
                  height: 5,
                  child: Container(
                    color: Colors.brown[800],
                  ),
                ),
              ),
            ),
          ),

          // Bird
          Positioned(
            left: gameLogic.bird.x - (gameLogic.bird.size / 2),
            top: gameLogic.bird.y - (gameLogic.bird.size / 2),
            child: AnimatedBuilder(
              animation: flapController ?? const AlwaysStoppedAnimation(0),
              builder: (context, child) {
                return Transform.rotate(
                  angle: gameLogic.bird.velocity * 0.05,
                  child: SizedBox(
                    width: gameLogic.bird.size,
                    height: gameLogic.bird.size - (flapAnimation?.value ?? 0) * 5,
                    child: BirdWidget(bird: gameLogic.bird),
                  ),
                );
              },
            ),
          ),

          // Score Display
          ScoreDisplay(
            score: gameLogic.score,
          ),

          // Game Overlay
          if (gameLogic.gameState != GameState.playing || isPaused)
            GameOverlay(
              gameLogic: gameLogic,
              isPaused: isPaused,
            ),
        ],
      ),
    );
  }
}
