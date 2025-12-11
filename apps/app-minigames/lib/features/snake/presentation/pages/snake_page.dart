// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

// Presentation imports:
import '../providers/snake_game_notifier.dart';
import '../game/snake_game.dart';

// Domain imports:
import '../../domain/entities/enums.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/power_up.dart';

/// Snake game page with Neon Arcade theme
class SnakePage extends ConsumerStatefulWidget {
  const SnakePage({super.key});

  @override
  ConsumerState<SnakePage> createState() => _SnakePageState();
}

class _SnakePageState extends ConsumerState<SnakePage> {
  late SnakeGame _game;
  int _currentScore = 0;
  List<ActivePowerUp> _activePowerUps = [];

  @override
  void initState() {
    super.initState();
    _game = SnakeGame(
      onScoreChanged: (score) {
        setState(() {
          _currentScore = score;
        });
      },
      onActivePowerUpsChanged: (powerUps) {
        setState(() {
          _activePowerUps = powerUps;
        });
      },
      onGameOver: () {
        final notifier = ref.read(snakeGameProvider.notifier);
        notifier.saveScore(_game.score);
        setState(() {}); // Rebuild to show game over overlay
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(snakeGameProvider);
    final notifier = ref.read(snakeGameProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'NEON SNAKE',
          style: TextStyle(
            fontFamily: 'Orbitron', // Assuming a techy font, or fallback
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.greenAccent,
                blurRadius: 10,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _game.restartGame();
            },
            tooltip: 'Reiniciar',
          ),
          IconButton(
            icon: Icon(
              !_game.isPlaying
                  ? Icons.play_arrow
                  : Icons.pause,
              color: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              if (_game.isPlaying) {
                _game.pauseGame();
              } else {
                _game.startGame();
              }
              setState(() {});
            },
            tooltip: 'Pausar/Continuar',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0F0F1A),
            ],
          ),
        ),
        child: Stack(
          children: [
            GameWidget(
              game: _game,
            ),
            
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 60),
                
                // HUD (Heads Up Display)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassScoreCard(
                        'SCORE', 
                        _currentScore.toString(), 
                        Colors.greenAccent,
                      ),
                      _buildGlassScoreCard('BEST', notifier.highScore.toString(), Colors.amberAccent),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),

                // Active Power-Ups Bar
                if (_activePowerUps.isNotEmpty)
                  _buildActivePowerUpsBar(_activePowerUps),

                const Spacer(),

                // Mobile Controls
                if (MediaQuery.of(context).size.width < 800)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32, top: 16),
                    child: _buildMobileControls(_game),
                  ),
              ],
            ),

            // Overlays
            if (!_game.isPlaying && !_game.isGameOver && _currentScore == 0)
              _buildOverlay(
                context,
                title: 'NEON SNAKE',
                buttonText: 'START GAME',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _game.startGame();
                  setState(() {});
                },
              ),

            if (_game.isGameOver)
              _buildOverlay(
                context,
                title: 'GAME OVER',
                subtitle: 'SCORE: $_currentScore',
                buttonText: 'TRY AGAIN',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _game.restartGame();
                  setState(() {});
                },
                color: Colors.black.withOpacity(0.85),
                isError: true,
              ),

            if (!_game.isPlaying && !_game.isGameOver && _currentScore > 0)
              _buildOverlay(
                context,
                title: 'PAUSED',
                buttonText: 'RESUME',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _game.startGame();
                  setState(() {});
                },
                color: Colors.black.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePowerUpsBar(List<ActivePowerUp> activePowerUps) {
    final activeOnes = activePowerUps.where((p) => p.isActive).toList();
    if (activeOnes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: activeOnes
            .map((p) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildPowerUpIndicator(p),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPowerUpIndicator(ActivePowerUp powerUp) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: powerUp.type.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: powerUp.type.color.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: powerUp.remainingPercent,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(powerUp.type.color),
                ),
              ),
              // Emoji
              Text(
                powerUp.type.emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassScoreCard(String label, String value, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    Color? color,
    bool isError = false,
  }) {
    return Container(
      color: color ?? Colors.black.withValues(alpha: 0.7),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isError ? Colors.redAccent : Colors.greenAccent,
                  shadows: [
                    BoxShadow(
                      color: (isError ? Colors.redAccent : Colors.greenAccent).withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                  letterSpacing: 4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  shadowColor: (isError ? Colors.redAccent : Colors.greenAccent).withValues(alpha: 0.5),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileControls(dynamic notifier) {
    return Column(
      children: [
        _buildControlButton(Icons.keyboard_arrow_up, () => notifier.changeDirection(Direction.up)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(Icons.keyboard_arrow_left, () => notifier.changeDirection(Direction.left)),
            const SizedBox(width: 60),
            _buildControlButton(Icons.keyboard_arrow_right, () => notifier.changeDirection(Direction.right)),
          ],
        ),
        _buildControlButton(Icons.keyboard_arrow_down, () => notifier.changeDirection(Direction.down)),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
