import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/pause_menu_overlay.dart';
import '../../game/centipede_game.dart';
import '../providers/centipede_providers.dart';
import '../widgets/game_over_overlay.dart';

/// Main page for Centipede game
class CentipedePage extends ConsumerStatefulWidget {
  const CentipedePage({super.key});

  @override
  ConsumerState<CentipedePage> createState() => _CentipedePageState();
}

class _CentipedePageState extends ConsumerState<CentipedePage> {
  late CentipedeGame _game;
  int _score = 0;
  int _lives = 3;
  int _wave = 1;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _game = CentipedeGame(
      onScoreChanged: (score) {
        if (mounted) {
          setState(() => _score = score);
        }
      },
      onLivesChanged: (lives) {
        if (mounted) {
          setState(() => _lives = lives);
        }
      },
      onWaveChanged: (wave) {
        if (mounted) {
          setState(() => _wave = wave);
        }
      },
      onGameOver: () {
        if (mounted) {
          setState(() => _isGameOver = true);
          // Save high score
          Future.microtask(() {
            if (mounted) {
              ref.read(centipedeHighScoreProvider.notifier).saveHighScore(_score);
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final highScoreAsync = ref.watch(centipedeHighScoreProvider);
    final highScore = highScoreAsync.value ?? 0;

    return GamePageLayout(
      title: 'Centipede',
      accentColor: const Color(0xFF00FF00),
      scrollable: false,
      instructions: 'Destrua a centopeia!\n\n'
          '🎯 Atire nos segmentos\n'
          '🍄 Cogumelos bloqueiam caminho\n'
          '🕷️ Aranha = bônus de pontos\n'
          '⌨️ WASD/Setas + Espaço para atirar',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Reiniciar',
          onPressed: _restartGame,
        ),
      ],
      child: Stack(
        children: [
          // Game
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GameWidget(
              game: _game,
              overlayBuilderMap: {
                'PauseMenu': (context, game) {
                  final typedGame = game as CentipedeGame;
                  return PauseMenuOverlay(
                    onContinue: typedGame.resumeGame,
                    onRestart: typedGame.restartFromPause,
                    accentColor: const Color(0xFF00FF00),
                  );
                },
              },
            ),
          ),
          
          // HUD - Score, Lives, Wave
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                _buildHudItem('SCORE', '$_score', Colors.yellow),
                // Wave
                _buildHudItem('WAVE', '$_wave', Colors.cyan),
                // Lives
                _buildHudItem('LIVES', '❤️' * _lives, Colors.red),
              ],
            ),
          ),
          
          // High Score
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'HI: $highScore',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Game Over Overlay
          if (_isGameOver)
            GameOverOverlay(
              score: _score,
              highScore: highScore,
              wave: _wave,
              onRestart: _restartGame,
            ),
        ],
      ),
    );
  }

  Widget _buildHudItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _wave = 1;
      _isGameOver = false;
    });
    _game.restart();
  }
}
