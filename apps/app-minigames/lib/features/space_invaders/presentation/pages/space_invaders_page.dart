import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../game/space_invaders_game.dart';

class SpaceInvadersPage extends StatelessWidget {
  const SpaceInvadersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Space Invaders',
      accentColor: const Color(0xFF4CAF50),
      instructions: 'Arraste para mover, toque para atirar.\n\n'
          '👾 Destrua os invasores\n'
          '🛡️ Defenda a Terra\n'
          '❤️ Você tem 3 vidas',
      maxGameWidth: 500,
      child: AspectRatio(
        aspectRatio: 0.7,
        child: GameWidget<SpaceInvadersGame>(
          game: SpaceInvadersGame(),
          overlayBuilderMap: {
            'GameOver': (context, game) => _buildOverlay(
              'Game Over',
              'Score: ${game.score}',
              Colors.red,
              game.reset,
            ),
            'GameWon': (context, game) => _buildOverlay(
              'Vitória!',
              'Score: ${game.score}',
              Colors.green,
              game.reset,
            ),
          },
        ),
      ),
    );
  }

  Widget _buildOverlay(
    String title,
    String subtitle,
    Color color,
    VoidCallback onRestart,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Jogar novamente',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
