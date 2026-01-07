import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../game/dino_run_game.dart';

class DinoRunPage extends StatelessWidget {
  const DinoRunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Dino Run',
      accentColor: const Color(0xFF8D6E63),
      instructions: 'Toque ou pressione espaço para pular.\n\n'
          '🌵 Evite os obstáculos\n'
          '⭐ Colete pontos\n'
          '🏃 Quanto mais longe, mais rápido!',
      maxGameWidth: 700,
      child: AspectRatio(
        aspectRatio: 1.8,
        child: GameWidget<DinoRunGame>(
          game: DinoRunGame(),
          overlayBuilderMap: {
            'GameOver': (context, game) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Score: ${game.score.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => game.reset(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6E63),
                        ),
                        child: const Text('Jogar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            },
          },
        ),
      ),
    );
  }
}
