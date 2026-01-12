import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/pause_menu_overlay.dart';
import '../../domain/entities/frogger_score.dart';
import '../../game/frogger_game.dart';
import '../providers/frogger_data_providers.dart';
import 'frogger_high_scores_page.dart';
import 'frogger_settings_page.dart';

class FroggerPage extends ConsumerStatefulWidget {
  const FroggerPage({super.key});

  @override
  ConsumerState<FroggerPage> createState() => _FroggerPageState();
}

class _FroggerPageState extends ConsumerState<FroggerPage> {
  late FroggerGame _game;

  @override
  void initState() {
    super.initState();
    _game = FroggerGame();
  }

  Future<void> _saveScoreAndRestart() async {
    if (_game.score > 0 && _game.gameStartTime != null) {
      final score = FroggerScore(
        score: _game.score,
        level: _game.level,
        crossingsCompleted: _game.crossingsCompleted,
        timestamp: DateTime.now(),
      );

      await ref.read(saveScoreUseCaseProvider).call(score);
      ref.invalidate(froggerHighScoresProvider);
      ref.invalidate(froggerStatsProvider);
    }

    _game.restartGame();
  }

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Frogger',
      accentColor: const Color(0xFF4CAF50),
      instructions: 'Toque ou use as setas para mover o sapo.\n\n'
          '🚗 Evite os carros na rua\n'
          '🪵 Pule nos troncos no rio\n'
          '🎯 Chegue nas 5 metas no topo',
      maxGameWidth: 500,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events),
          tooltip: 'High Scores',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FroggerHighScoresPage(),
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
                builder: (_) => const FroggerSettingsPage(),
              ),
            );
          },
        ),
      ],
      child: AspectRatio(
        aspectRatio: 0.7,
        child: GameWidget(
          game: _game,
          backgroundBuilder: (context) => Container(
            color: const Color(0xFF1A1A2E),
          ),
          overlayBuilderMap: {
            'PauseMenu': (context, game) {
              final typedGame = game as FroggerGame;
              return PauseMenuOverlay(
                onContinue: typedGame.resumeGame,
                onRestart: typedGame.restartFromPause,
                accentColor: const Color(0xFF4CAF50),
              );
            },
            'GameOver': (context, game) => Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Score: ${_game.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level: ${_game.level}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveScoreAndRestart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
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
