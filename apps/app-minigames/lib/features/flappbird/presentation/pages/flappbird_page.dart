// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

// Core imports:
import '../../../../core/widgets/game_page_layout.dart';

// Presentation imports:
import '../providers/flappbird_notifier.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/game_over_dialog.dart';
import '../game/flappy_bird_game.dart';

/// Main Flappy Bird game page
class FlappbirdPage extends ConsumerStatefulWidget {
  const FlappbirdPage({super.key});

  @override
  ConsumerState<FlappbirdPage> createState() => _FlappbirdPageState();
}

class _FlappbirdPageState extends ConsumerState<FlappbirdPage> {
  late FlappyBirdGame _game;
  int _currentScore = 0;

  @override
  void initState() {
    super.initState();
    _game = FlappyBirdGame(
      onScoreChanged: (score) {
        setState(() {
          _currentScore = score;
        });
      },
      onGameOver: () {
        final notifier = ref.read(flappbirdGameProvider.notifier);
        notifier.saveScore(_game.score);
        setState(() {}); // Rebuild to show game over overlay if needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to get high score updates
    ref.watch(flappbirdGameProvider);
    final highScore = ref.read(flappbirdGameProvider.notifier).highScore;

    return GamePageLayout(
      title: 'Flappy Bird',
      accentColor: const Color(0xFF4CAF50),
      instructions: 'Toque na tela para voar!\n\n'
          '🐦 Desvie dos canos\n'
          '⭐ Passe entre os obstáculos\n'
          '🏆 Bata seu recorde!',
      maxGameWidth: 500,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Reiniciar',
          onPressed: () => _game.restartGame(),
        ),
      ],
      child: AspectRatio(
        aspectRatio: 0.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GameWidget(
            game: _game,
            overlayBuilderMap: {
              'Score': (context, FlappyBirdGame game) {
                return ScoreDisplayWidget(
                  score: _currentScore,
                  highScore: highScore,
                );
              },
              'GameOver': (context, FlappyBirdGame game) {
                return GameOverDialog(
                  score: _currentScore,
                  highScore: highScore,
                  onRestart: () {
                    game.restartGame();
                  },
                );
              },
              'Start': (context, FlappyBirdGame game) {
                return IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Toque para Iniciar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            },
            initialActiveOverlays: const ['Score'],
          ),
        ),
      ),
    );
  }
}

