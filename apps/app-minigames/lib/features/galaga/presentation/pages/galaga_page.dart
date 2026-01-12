import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/pause_menu_overlay.dart';
import '../../domain/entities/galaga_score.dart';
import '../../game/galaga_game.dart';
import '../providers/galaga_data_providers.dart';
import 'galaga_high_scores_page.dart';
import 'galaga_settings_page.dart';

class GalagaPage extends ConsumerStatefulWidget {
  const GalagaPage({super.key});

  @override
  ConsumerState<GalagaPage> createState() => _GalagaPageState();
}

class _GalagaPageState extends ConsumerState<GalagaPage> {
  late GalagaGame _game;

  @override
  void initState() {
    super.initState();
    _game = GalagaGame();
  }

  Future<void> _saveScoreAndRestart() async {
    if (_game.score > 0 && _game.gameStartTime != null) {
      final score = GalagaScore(
        score: _game.score,
        wave: _game.wave,
        enemiesDestroyed: _game.enemiesDestroyed,
        timestamp: DateTime.now(),
      );

      await ref.read(saveScoreUseCaseProvider).call(score);
      ref.invalidate(galagaHighScoresProvider);
      ref.invalidate(galagaStatsProvider);
    }

    _game.restartGame();
  }

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Galaga',
      accentColor: const Color(0xFF00BCD4),
      instructions: 'Arraste para mover a nave.\n'
          'Toque para atirar.\n\n'
          '🟢 Inimigo básico: 50pts\n'
          '🟡 Atirador: 100pts\n'
          '🔴 Mergulhador: 150pts',
      maxGameWidth: 500,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events),
          tooltip: 'High Scores',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GalagaHighScoresPage(),
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
                builder: (_) => const GalagaSettingsPage(),
              ),
            );
          },
        ),
      ],
      child: AspectRatio(
        aspectRatio: 0.65,
        child: GameWidget(
          game: _game,
          backgroundBuilder: (context) => Container(
            color: const Color(0xFF000011),
          ),
          overlayBuilderMap: {
            'PauseMenu': (context, game) {
              final typedGame = game as GalagaGame;
              return PauseMenuOverlay(
                onContinue: typedGame.resumeGame,
                onRestart: typedGame.restartFromPause,
                accentColor: const Color(0xFF00BCD4),
              );
            },
            'GameOver': (context, game) => Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00BCD4), width: 2),
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
                      'Wave: ${_game.wave}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveScoreAndRestart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
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
