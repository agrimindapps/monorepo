import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/pause_menu_overlay.dart';
import '../../domain/entities/space_invaders_score.dart';
import '../../game/space_invaders_game.dart';
import '../providers/space_invaders_data_providers.dart';
import 'space_invaders_high_scores_page.dart';
import 'space_invaders_settings_page.dart';

class SpaceInvadersPage extends ConsumerStatefulWidget {
  const SpaceInvadersPage({super.key});

  @override
  ConsumerState<SpaceInvadersPage> createState() => _SpaceInvadersPageState();
}

class _SpaceInvadersPageState extends ConsumerState<SpaceInvadersPage> {
  late SpaceInvadersGame _game;

  @override
  void initState() {
    super.initState();
    _game = SpaceInvadersGame();
  }

  Future<void> _saveScoreAndReset() async {
    if (_game.gameStartTime != null && _game.score > 0) {
      final duration = DateTime.now().difference(_game.gameStartTime!);
      final score = SpaceInvadersScore(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        score: _game.score,
        wave: _game.wave,
        invadersKilled: _game.invadersKilled,
        duration: duration,
        completedAt: DateTime.now(),
      );

      final saver = ref.read(spaceInvadersScoreSaverProvider.notifier);
      await saver.saveScore(score);
    }
    _game.reset();
  }

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
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SpaceInvadersHighScoresPage()),
            );
          },
          tooltip: 'High Scores',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SpaceInvadersSettingsPage()),
            );
          },
          tooltip: 'Configurações',
        ),
      ],
      child: AspectRatio(
        aspectRatio: 0.7,
        child: GameWidget<SpaceInvadersGame>(
          game: _game,
          overlayBuilderMap: {
            'PauseMenu': (context, game) => PauseMenuOverlay(
              onContinue: game.resumeGame,
              onRestart: game.restartFromPause,
              accentColor: const Color(0xFF4CAF50),
            ),
            'GameOver': (context, game) => _buildOverlay(
              'Game Over',
              'Score: ${game.score}',
              Colors.red,
              _saveScoreAndReset,
            ),
            'GameWon': (context, game) => _buildOverlay(
              'Vitória!',
              'Score: ${game.score}',
              Colors.green,
              _saveScoreAndReset,
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
