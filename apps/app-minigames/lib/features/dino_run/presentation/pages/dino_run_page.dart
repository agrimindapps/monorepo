import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/game_page_layout.dart';
import '../../../../../core/widgets/pause_menu_overlay.dart';
import '../../../domain/entities/dino_run_score.dart';
import '../../game/dino_run_game.dart';
import '../../providers/dino_run_data_providers.dart';
import 'dino_run_high_scores_page.dart';
import 'dino_run_settings_page.dart';

class DinoRunPage extends ConsumerStatefulWidget {
  const DinoRunPage({super.key});

  @override
  ConsumerState<DinoRunPage> createState() => _DinoRunPageState();
}

class _DinoRunPageState extends ConsumerState<DinoRunPage> {
  DinoRunGame? _game;
  int _score = 0;
  int _highScore = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _game = DinoRunGame(
      onScoreChanged: (score) {
        if (mounted) setState(() => _score = score);
      },
      onHighScoreChanged: (highScore) {
        if (mounted) setState(() => _highScore = highScore);
      },
      onGameOver: () {
        if (mounted) setState(() => _isGameOver = true);
      },
    );
  }

  Future<void> _restartGame() async {
    // Save score before restarting
    if (_score > 0 && _game?.gameStartTime != null) {
      final score = DinoRunScore(
        score: _score,
        distance: _score, // Using score as distance
        obstaclesJumped: _game!.obstaclesJumped,
        timestamp: DateTime.now(),
      );

      await ref.read(saveScoreUseCaseProvider).call(score);
      ref.invalidate(dinoRunHighScoresProvider);
      ref.invalidate(dinoRunStatsProvider);
    }

    _game?.reset();
    setState(() {
      _score = 0;
      _isGameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Dino Run',
      accentColor: const Color(0xFF535353),
      instructions: 'Toque ou pressione ESPAÇO para pular!\n\n'
          '🦖 Controles:\n'
          '   • Toque / Espaço / ↑ = Pular\n'
          '   • ↓ = Abaixar\n\n'
          '🌵 Evite os cactos\n'
          '🦅 Cuidado com os pterodáctilos\n'
          '🌙 Ciclo dia/noite a cada 30s\n'
          '⚡ Velocidade aumenta com o tempo!',
      maxGameWidth: 800,
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events),
          tooltip: 'High Scores',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DinoRunHighScoresPage(),
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
                builder: (_) => const DinoRunSettingsPage(),
              ),
            );
          },
        ),
        if (_highScore > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              backgroundColor: Colors.amber.withValues(alpha: 0.2),
              avatar: const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
              label: Text(
                'HI: $_highScore',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
      child: AspectRatio(
        aspectRatio: 2.0, // Wider for better dino run experience
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Game widget
              if (_game != null)
                GestureDetector(
                  onTapDown: (_) {
                    if (!_isGameOver) {
                      if (!_game!.isPlaying) {
                        _game!.startGame();
                      } else {
                        _game!.dino.jump();
                      }
                    }
                  },
                  onLongPressStart: (_) {
                    if (_game!.isPlaying && !_isGameOver) {
                      _game!.dino.duck();
                    }
                  },
                  onLongPressEnd: (_) {
                    _game!.dino.standUp();
                  },
                  child: GameWidget<DinoRunGame>(
                    game: _game!,
                    overlayBuilderMap: {
                      'PauseMenu': (context, game) => PauseMenuOverlay(
                        onContinue: game.resumeGame,
                        onRestart: game.restartFromPause,
                        accentColor: const Color(0xFF535353),
                      ),
                      'GameOver': (context, game) =>
                          _buildGameOverOverlay(context, game),
                    },
                  ),
                ),

              // Start prompt (only before game starts)
              if (_game != null && !_game!.isPlaying && !_isGameOver)
                _buildStartPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartPrompt() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated dino icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.bounceOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF535353),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    '🦖',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'DINO RUN',
                style: TextStyle(
                  color: Color(0xFF535353),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Color(0xFF535353)),
                    SizedBox(width: 8),
                    Text(
                      'Toque para começar',
                      style: TextStyle(
                        color: Color(0xFF535353),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(BuildContext context, DinoRunGame game) {
    final isNewHighScore = _score >= _highScore && _highScore > 0;

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Over icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '💀',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: Color(0xFF535353),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),

                // Score display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _score.toString().padLeft(5, '0'),
                        style: const TextStyle(
                          color: Color(0xFF535353),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 4,
                        ),
                      ),
                      if (isNewHighScore) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'NOVO RECORDE!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Restart button
                ElevatedButton(
                  onPressed: _restartGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF535353),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay),
                      SizedBox(width: 8),
                      Text(
                        'Jogar Novamente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
