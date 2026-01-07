import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../game/arkanoid_game.dart';

class ArkanoidPage extends StatelessWidget {
  const ArkanoidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkanoid'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: GameWidget<ArkanoidGame>(
        game: ArkanoidGame(),
        overlayBuilderMap: {
          'GameOver': (context, game) => _buildOverlay(
            context,
            'Game Over',
            'Score: ${game.score}',
            'Try Again',
            game.reset,
          ),
          'GameWon': (context, game) => _buildOverlay(
            context,
            'You Win!',
            'Score: ${game.score}',
            'Play Again',
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
    String buttonText,
    VoidCallback onAction,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
