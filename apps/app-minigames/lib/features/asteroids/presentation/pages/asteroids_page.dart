import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../game/asteroids_game.dart';

class AsteroidsPage extends StatelessWidget {
  const AsteroidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Asteroids',
      accentColor: const Color(0xFF00BCD4),
      instructions: '← → Rotacionar\n'
          '↑ Acelerar\n'
          'Espaço/Toque para atirar\n\n'
          '☄️ Destrua os asteroides\n'
          '💥 Asteroides grandes se dividem',
      maxGameWidth: 600,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GameWidget<AsteroidsGame>(
          game: AsteroidsGame(),
          overlayBuilderMap: {
            'GameOver': (context, game) => Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyan, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Game Over',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Score: ${game.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: game.reset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Jogar novamente',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          },
        ),
      ),
    );
  }
}
