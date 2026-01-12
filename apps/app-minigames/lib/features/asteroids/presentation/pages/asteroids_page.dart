import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/pause_menu_overlay.dart';
import '../../domain/entities/asteroids_score.dart';
import '../../game/asteroids_game.dart';
import '../providers/asteroids_data_providers.dart';
import 'asteroids_high_scores_page.dart';
import 'asteroids_settings_page.dart';

class AsteroidsPage extends ConsumerStatefulWidget {
  const AsteroidsPage({super.key});

  @override
  ConsumerState<AsteroidsPage> createState() => _AsteroidsPageState();
}

class _AsteroidsPageState extends ConsumerState<AsteroidsPage> {
  late AsteroidsGame _game;

  @override
  void initState() {
    super.initState();
    _game = AsteroidsGame();
  }

  Future<void> _saveScoreAndReset() async {
    if (_game.score > 0 && _game.gameStartTime != null) {
      final score = AsteroidsScore(
        score: _game.score,
        wave: _game.wave,
        asteroidsDestroyed: _game.asteroidsDestroyed,
        timestamp: DateTime.now(),
      );

      await ref.read(saveScoreUseCaseProvider).call(score);
      ref.invalidate(asteroidsHighScoresProvider);
      ref.invalidate(asteroidsStatsProvider);
    }

    _game.reset();
  }

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
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events),
          tooltip: 'High Scores',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AsteroidsHighScoresPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Configurações',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AsteroidsSettingsPage(),
              ),
            );
          },
        ),
      ],
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GameWidget<AsteroidsGame>(
          game: _game,
          overlayBuilderMap: {
            'PauseMenu': (context, game) => PauseMenuOverlay(
              onContinue: game.resumeGame,
              onRestart: game.restartFromPause,
              accentColor: const Color(0xFF00BCD4),
            ),
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
                      onPressed: _saveScoreAndReset,
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
