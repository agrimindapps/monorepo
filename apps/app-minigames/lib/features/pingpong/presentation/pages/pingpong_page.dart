import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../domain/entities/enums.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/game_over_dialog.dart';
import '../game/ping_pong_game.dart';

class PingpongPage extends ConsumerStatefulWidget {
  const PingpongPage({super.key});

  @override
  ConsumerState<PingpongPage> createState() => _PingpongPageState();
}

class _PingpongPageState extends ConsumerState<PingpongPage> {
  PingPongGame? _game;
  int _playerScore = 0;
  int _aiScore = 0;
  GameDifficulty _difficulty = GameDifficulty.medium;
  bool _gameStarted = false;
  bool _isPlaying = false;
  bool _isGameOver = false;

  void _initGame() {
    _game = PingPongGame(
      difficulty: _difficulty,
      onPlayerScoreChanged: (score) {
        if (mounted) {
          setState(() {
            _playerScore = score;
          });
        }
      },
      onAiScoreChanged: (score) {
        if (mounted) {
          setState(() {
            _aiScore = score;
          });
        }
      },
      onGameOver: () {
        if (mounted) {
          setState(() {
            _isGameOver = true;
            _isPlaying = false;
          });
        }
      },
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _playerScore = 0;
      _aiScore = 0;
      _isGameOver = false;
      _isPlaying = false;
    });
    _initGame();
    
    // Start the game after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _game != null) {
        _game!.startGame();
        setState(() {
          _isPlaying = true;
        });
      }
    });
  }

  void _togglePause() {
    if (_game == null) return;
    
    if (_isPlaying) {
      _game!.pauseGame();
      setState(() => _isPlaying = false);
    } else {
      _game!.startGame();
      setState(() => _isPlaying = true);
    }
  }

  void _restartGame() {
    if (_game != null) {
      _game!.restartGame();
      setState(() {
        _playerScore = 0;
        _aiScore = 0;
        _isGameOver = false;
        _isPlaying = false;
      });
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _game != null) {
          _game!.startGame();
          setState(() => _isPlaying = true);
        }
      });
    }
  }

  void _exitToMenu() {
    setState(() {
      _gameStarted = false;
      _isPlaying = false;
      _isGameOver = false;
      _playerScore = 0;
      _aiScore = 0;
      _game = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GamePageLayout(
      title: 'Ping Pong',
      accentColor: const Color(0xFF00BCD4),
      instructions: 'Arraste para mover sua raquete!\n\n'
          '🏓 Rebata a bola\n'
          '🤖 Vença a IA\n'
          '🎯 Primeiro a 11 pontos vence!',
      maxGameWidth: 600,
      actions: _gameStarted
          ? [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _isGameOver ? null : _togglePause,
                tooltip: _isPlaying ? 'Pausar' : 'Continuar',
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _restartGame,
                tooltip: 'Reiniciar',
              ),
            ]
          : [],
      child: !_gameStarted ? _buildMenu() : _buildGame(),
    );
  }

  Widget _buildMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.sports_tennis,
          size: 80,
          color: Color(0xFF00BCD4),
        ),
        const SizedBox(height: 24),
        const Text(
          'PING PONG',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha a dificuldade',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 40),
        _buildDifficultyButton('Fácil', GameDifficulty.easy, const Color(0xFF4CAF50)),
        const SizedBox(height: 12),
        _buildDifficultyButton('Médio', GameDifficulty.medium, const Color(0xFFFF9800)),
        const SizedBox(height: 12),
        _buildDifficultyButton('Difícil', GameDifficulty.hard, const Color(0xFFF44336)),
      ],
    );
  }

  Widget _buildDifficultyButton(String label, GameDifficulty difficulty, Color color) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          _difficulty = difficulty;
          _startGame();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    // Use AspectRatio to give the game a fixed proportion
    // Ping pong is wider than tall, so use 3:2 aspect ratio
    return AspectRatio(
      aspectRatio: 1.5, // width / height = 3:2
      child: Stack(
        children: [
          // Game widget
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _game != null
                ? GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (_isPlaying && _game != null) {
                        _game!.movePlayerPaddle(details.delta.dy);
                      }
                    },
                    onTap: () {
                      // Tap to start if paused
                      if (!_isPlaying && !_isGameOver && _game != null) {
                        _game!.startGame();
                        setState(() => _isPlaying = true);
                      }
                    },
                    child: GameWidget(
                      game: _game!,
                      backgroundBuilder: (_) => Container(
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                  ),
          ),

          // Score display
          ScoreDisplayWidget(
            playerScore: _playerScore,
            aiScore: _aiScore,
          ),

          // Pause overlay
          if (!_isPlaying && !_isGameOver)
            _buildPauseOverlay(),

          // Game over dialog
          if (_isGameOver)
            GameOverDialog(
              playerWon: _playerScore > _aiScore,
              finalScore: _playerScore * 100,
              gameDuration: _game?.elapsedDuration ?? Duration.zero,
              highScore: null,
              onPlayAgain: _restartGame,
              onExit: _exitToMenu,
            ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app,
                color: Colors.white70,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'TOQUE PARA JOGAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Arraste para mover a raquete',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
