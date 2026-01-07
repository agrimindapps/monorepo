import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../game/arkanoid_game.dart';

class ArkanoidPage extends StatelessWidget {
  const ArkanoidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Arkanoid',
      accentColor: const Color(0xFF00BCD4),
      instructions: 'Arraste para mover a raquete.\n\n'
          '🟦 Destrua todos os blocos\n'
          '⚪ Não deixe a bola cair\n'
          '🏆 Marque o máximo de pontos!',
      maxGameWidth: 500,
      child: AspectRatio(
        aspectRatio: 0.7,
        child: GameWidget<ArkanoidGame>(
          game: ArkanoidGame(),
          overlayBuilderMap: {
            'GameOver': (context, game) => _buildOverlay(
              'Game Over',
              'Score: ${game.score}',
              'Jogar novamente',
              game.reset,
              Colors.red,
            ),
            'GameWon': (context, game) => _buildOverlay(
              'Você Venceu!',
              'Score: ${game.score}',
              'Jogar novamente',
              game.reset,
              Colors.green,
            ),
          },
        ),
      ),
    );
  }

  Widget _buildOverlay(
    String title,
    String subtitle,
    String buttonText,
    VoidCallback onAction,
    Color color,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
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
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
