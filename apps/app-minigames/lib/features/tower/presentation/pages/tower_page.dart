import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

import '../providers/tower_game_notifier.dart';
import '../game/tower_stack_game.dart';
import '../widgets/game_over_dialog.dart';

/// Main page for Tower Stack game
class TowerPage extends ConsumerStatefulWidget {
  const TowerPage({super.key});

  @override
  ConsumerState<TowerPage> createState() => _TowerPageState();
}

class _TowerPageState extends ConsumerState<TowerPage> {
  late TowerStackGame _game;
  int _currentScore = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _game = TowerStackGame(
      onScoreChanged: (score) {
        setState(() {
          _currentScore = score;
        });
      },
      onGameOver: () {
        setState(() {
          _isGameOver = true;
        });
        // Save high score
        final notifier = ref.read(towerGameProvider(MediaQuery.of(context).size.width).notifier);
        notifier.saveScore(_currentScore);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Initialize provider to load high score
    ref.watch(towerGameProvider(screenWidth));
    final notifier = ref.read(towerGameProvider(screenWidth).notifier);

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          
          // Score Display
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '$_currentScore',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Best: ${notifier.highScore}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Start Instruction
          if (_currentScore == 0 && !_isGameOver)
            const Center(
              child: Text(
                'Tap to Place Block',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            
          // Game Over Dialog
          if (_isGameOver)
            GameOverDialog(
              score: _currentScore,
              highScore: notifier.highScore,
              combo: _game.combo,
              onRestart: () {
                setState(() {
                  _isGameOver = false;
                  _currentScore = 0;
                });
                _game.resetGame();
              },
              onExit: () => Navigator.of(context).pop(),
            ),
            
          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

