import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/pause_menu_overlay.dart';
import '../../domain/entities/arkanoid_score.dart';
import '../../game/arkanoid_game.dart';
import '../providers/arkanoid_data_providers.dart';
import 'arkanoid_high_scores_page.dart';
import 'arkanoid_settings_page.dart';

class ArkanoidPage extends ConsumerStatefulWidget {
  const ArkanoidPage({super.key});

  @override
  ConsumerState<ArkanoidPage> createState() => _ArkanoidPageState();
}

class _ArkanoidPageState extends ConsumerState<ArkanoidPage> {
  late ArkanoidGame _game;

  @override
  void initState() {
    super.initState();
    _game = ArkanoidGame();
  }

  Future<void> _saveScoreAndReset() async {
    if (_game.gameStartTime != null && _game.score > 0) {
      final duration = DateTime.now().difference(_game.gameStartTime!);
      final score = ArkanoidScore(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        score: _game.score,
        level: _game.level,
        bricksDestroyed: _game.bricksDestroyed,
        duration: duration,
        completedAt: DateTime.now(),
      );

      final saver = ref.read(arkanoidScoreSaverProvider.notifier);
      await saver.saveScore(score);
    }
    _game.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Arkanoid',
      accentColor: const Color(0xFFFF5722),
      instructions: 'Destrua todos os tijolos!\n\n'
          '🎯 Arraste para mover a raquete\n'
          '⚽ Mantenha a bola em jogo\n'
          '🧱 Destrua todos os tijolos',
      maxGameWidth: 500,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ArkanoidHighScoresPage()));
          },
          tooltip: 'High Scores',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ArkanoidSettingsPage()));
          },
          tooltip: 'Configurações',
        ),
      ],
      child: AspectRatio(
        aspectRatio: 0.6,
        child: GameWidget<ArkanoidGame>(
          game: _game,
          overlayBuilderMap: {
            'PauseMenu': (context, game) => PauseMenuOverlay(
              onContinue: game.resumeGame,
              onRestart: game.reset,
              accentColor: const Color(0xFFFF5722),
            ),
            'GameOver': (context, game) => _buildOverlay('Game Over', 'Score: ${game.score}', Colors.red, _saveScoreAndReset),
            'GameWon': (context, game) => _buildOverlay('Vitória!', 'Score: ${game.score}', Colors.green, _saveScoreAndReset),
          },
        ),
      ),
    );
  }

  Widget _buildOverlay(String title, String subtitle, Color color, VoidCallback onRestart) {
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
            Text(title, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('Jogar novamente', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
