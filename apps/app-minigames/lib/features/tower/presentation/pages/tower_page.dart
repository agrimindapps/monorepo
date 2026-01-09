import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

import '../../../../core/widgets/game_page_layout.dart';
import '../../../../core/widgets/pause_menu_overlay.dart';
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
  int _currentCombo = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _game = TowerStackGame(
      onScoreChanged: (score) {
        if (mounted) {
          setState(() {
            _currentScore = score;
          });
        }
      },
      onComboChanged: (combo) {
        if (mounted) {
          setState(() {
            _currentCombo = combo;
          });
        }
      },
      onGameOver: () {
        if (mounted) {
          setState(() {
            _isGameOver = true;
          });
          // Save high score using deferred call to avoid build-time issues
          Future.microtask(() {
            if (mounted) {
              final notifier = ref.read(towerGameProvider(0).notifier);
              notifier.saveScore(_currentScore);
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize provider to load high score (use 0 as dummy parameter)
    ref.watch(towerGameProvider(0));
    final notifier = ref.read(towerGameProvider(0).notifier);

    return GamePageLayout(
      title: 'Tower Stack',
      accentColor: const Color(0xFFE91E63),
      scrollable: false, // Flame game needs Expanded, not ScrollView
      instructions: 'Empilhe os blocos!\n\n'
          '👆 Toque para soltar o bloco\n'
          '🎯 Alinhe perfeitamente para combo\n'
          '📏 Blocos desalinhados diminuem\n'
          '🏗️ Construa a torre mais alta!',
      maxGameWidth: 500,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Reiniciar',
          onPressed: () {
            setState(() {
              _isGameOver = false;
              _currentScore = 0;
              _currentCombo = 0;
            });
            _game.resetGame();
          },
        ),
      ],
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GameWidget(
              game: _game,
              overlayBuilderMap: {
                'PauseMenu': (context, game) {
                  final towerGame = game as TowerStackGame;
                  return PauseMenuOverlay(
                    onContinue: towerGame.resumeGame,
                    onRestart: towerGame.restartFromPause,
                    accentColor: const Color(0xFFE91E63),
                  );
                },
              },
            ),
          ),
          
          // Score Display
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '$_currentScore',
                  style: const TextStyle(
                    fontSize: 48,
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
                  'Recorde: ${notifier.highScore}',
                  style: const TextStyle(
                    fontSize: 16,
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
          
          // Combo Indicator
          if (_currentCombo > 0)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '🔥 Combo x$_currentCombo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          
          // Start Instruction
          if (_currentScore == 0 && !_isGameOver)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Toque para Soltar',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
          // Game Over Dialog
          if (_isGameOver)
            GameOverDialog(
              score: _currentScore,
              highScore: notifier.highScore,
              combo: _currentCombo,
              onRestart: () {
                setState(() {
                  _isGameOver = false;
                  _currentScore = 0;
                  _currentCombo = 0;
                });
                _game.resetGame();
              },
              onExit: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}

