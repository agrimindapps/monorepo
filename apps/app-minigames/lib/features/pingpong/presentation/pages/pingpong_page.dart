import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/enums.dart';
import '../providers/pingpong_notifier.dart';
import '../widgets/ball_widget.dart';
import '../widgets/paddle_widget.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/court_widget.dart';
import '../widgets/game_over_dialog.dart';

class PingpongPage extends ConsumerStatefulWidget {
  const PingpongPage({super.key});

  @override
  ConsumerState<PingpongPage> createState() => _PingpongPageState();
}

class _PingpongPageState extends ConsumerState<PingpongPage> {
  PaddleDirection _currentDirection = PaddleDirection.stop;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(pingpongGameProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: gameState.status == GameStatus.initial
            ? _buildMenu()
            : Stack(
                children: [
                  const CourtWidget(),
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (gameState.status != GameStatus.playing) return;

                      final direction = details.delta.dy < 0
                          ? PaddleDirection.up
                          : PaddleDirection.down;

                      if (_currentDirection != direction) {
                        _currentDirection = direction;
                        ref.read(pingpongGameProvider.notifier).movePaddle(direction);
                      }
                    },
                    onVerticalDragEnd: (_) {
                      _currentDirection = PaddleDirection.stop;
                    },
                    child: Container(color: Colors.transparent),
                  ),
                  PaddleWidget(
                    paddle: gameState.playerPaddle,
                    screenWidth: size.width,
                    screenHeight: size.height,
                  ),
                  PaddleWidget(
                    paddle: gameState.aiPaddle,
                    screenWidth: size.width,
                    screenHeight: size.height,
                  ),
                  BallWidget(
                    ball: gameState.ball,
                    screenWidth: size.width,
                    screenHeight: size.height,
                  ),
                  ScoreDisplayWidget(
                    playerScore: gameState.playerScore,
                    aiScore: gameState.aiScore,
                  ),
                  if (gameState.status == GameStatus.paused)
                    _buildPauseOverlay(),
                  if (gameState.isGameOver)
                    GameOverDialog(
                      playerWon: gameState.playerWon,
                      finalScore: gameState.calculateFinalScore(),
                      gameDuration: gameState.elapsedTime ?? Duration.zero,
                      highScore: gameState.highScore,
                      onPlayAgain: () {
                        ref.read(pingpongGameProvider.notifier).resetGame();
                        ref.read(pingpongGameProvider.notifier).startGame(gameState.difficulty);
                      },
                      onExit: () {
                        ref.read(pingpongGameProvider.notifier).resetGame();
                      },
                    ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        gameState.status == GameStatus.paused
                            ? Icons.play_arrow
                            : Icons.pause,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (gameState.status == GameStatus.paused) {
                          ref.read(pingpongGameProvider.notifier).resumeGame();
                        } else if (gameState.status == GameStatus.playing) {
                          ref.read(pingpongGameProvider.notifier).pauseGame();
                        }
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
        ref.read(pingpongGameProvider.notifier).startGame(difficulty);
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pause_circle_outline, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text(
              'PAUSADO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
