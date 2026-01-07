import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../game/space_invaders_game.dart';

class SpaceInvadersPage extends StatelessWidget {
  const SpaceInvadersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000020),
      appBar: AppBar(
        title: const Text('Space Invaders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
      ),
      body: GameWidget<SpaceInvadersGame>(
        game: SpaceInvadersGame(),
        overlayBuilderMap: {
          'GameOver': (context, game) => _buildOverlay(
            context,
            'Game Over',
            'Score: ${game.score}',
            Colors.red,
            game.reset,
          ),
          'GameWon': (context, game) => _buildOverlay(
            context,
            'Victory!',
            'Score: ${game.score}',
            Colors.green,
            game.reset,
          ),
        },
      ),
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    VoidCallback onRestart,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Play Again',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
