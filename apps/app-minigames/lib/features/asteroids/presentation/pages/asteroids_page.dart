import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../game/asteroids_game.dart';

class AsteroidsPage extends StatelessWidget {
  const AsteroidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Asteroids'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Stack(
        children: [
          GameWidget<AsteroidsGame>(
            game: AsteroidsGame(),
            overlayBuilderMap: {
              'GameOver': (context, game) => Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyan, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Score: ${game.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: game.reset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Play Again',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            },
          ),
          // Controls hint
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '← → Rotate  |  ↑ Thrust  |  Space/Tap Shoot',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
