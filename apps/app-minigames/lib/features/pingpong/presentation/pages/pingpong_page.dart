import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

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
  late PingPongGame _game;
  int _playerScore = 0;
  int _aiScore = 0;
  GameDifficulty _difficulty = GameDifficulty.medium;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }
  
  void _initGame() {
    _game = PingPongGame(
      difficulty: _difficulty,
      onPlayerScoreChanged: (score) {
        setState(() {
          _playerScore = score;
        });
      },
      onAiScoreChanged: (score) {
        setState(() {
          _aiScore = score;
        });
      },
      onGameOver: () {
        // Save score logic here if needed
        setState(() {}); // Rebuild to show game over overlay
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: !_gameStarted
            ? _buildMenu()
            : Stack(
                children: [
                  GameWidget(
                    game: _game,
                  ),
                  
                  // Touch controls overlay (invisible)
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (_game.isPlaying) {
                        _game.movePlayerPaddle(details.delta.dy);
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                  
                  ScoreDisplayWidget(
                    playerScore: _playerScore,
                    aiScore: _aiScore,
                  ),
                  
                  if (!_game.isPlaying && !_game.isGameOver)
                    _buildPauseOverlay(),
                    
                  if (_game.isGameOver)
                    GameOverDialog(
                      playerWon: _playerScore > _aiScore,
                      finalScore: _playerScore * 100, // Simplified score
                      gameDuration: Duration.zero, // TODO: Track duration
                      highScore: null, // TODO: Get high score
                      onPlayAgain: () {
                        _game.restartGame();
                        setState(() {});
                      },
                      onExit: () {
                        setState(() {
                          _gameStarted = false;
                        });
                      },
                    ),
                    
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        !_game.isPlaying
                            ? Icons.play_arrow
                            : Icons.pause,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (_game.isPlaying) {
                          _game.pauseGame();
                        } else {
                          _game.startGame();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMenu() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'PING PONG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 60),
          _buildDifficultyButton('Fácil', GameDifficulty.easy),
          const SizedBox(height: 16),
          _buildDifficultyButton('Médio', GameDifficulty.medium),
          const SizedBox(height: 16),
          _buildDifficultyButton('Difícil', GameDifficulty.hard),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            label: const Text(
              'Voltar',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String label, GameDifficulty difficulty) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _difficulty = difficulty;
          _gameStarted = true;
          _initGame();
          // Auto start after a short delay? Or let user press play
          Future.delayed(const Duration(milliseconds: 500), () {
             _game.startGame();
             setState(() {});
          });
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pause_circle_outline, color: Colors.white, size: 80),
            const SizedBox(height: 20),
            const Text(
              'PAUSADO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _game.startGame();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('CONTINUAR', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
