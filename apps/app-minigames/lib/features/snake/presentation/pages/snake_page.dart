// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

// Core imports:
import '../../../../core/widgets/game_page_layout.dart';

// Presentation imports:
import '../providers/snake_game_notifier.dart';
import '../game/snake_game.dart';

// Domain imports:
import '../../domain/entities/enums.dart';
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
        if (mounted) {
          setState(() {
            _currentScore = score;
          });
        }
      },
      onActivePowerUpsChanged: (powerUps) {
        if (mounted) {
          setState(() {
            _activePowerUps = powerUps;
          });
        }
      },
      onGameOver: () {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final notifier = ref.read(snakeGameProvider.notifier);
              notifier.saveScore(_game.score);
              setState(() {}); // Rebuild to show game over overlay
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(snakeGameProvider.notifier);
    final highScore = notifier.highScore;

    return GamePageLayout(
      title: 'Neon Snake',
      accentColor: Colors.greenAccent,
      instructions: 'Coma para crescer!\n\n'
          '🍎 Coma as frutas\n'
          '⚡ Colete power-ups\n'
          '🚫 Não bata nas paredes\n'
          '🐍 Não morda a si mesmo!',
      maxGameWidth: 600,
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
            !_game.isPlaying ? Icons.play_arrow : Icons.pause,
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
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GameWidget(game: _game),
          ),
        
          Column(
            children: [
              // HUD (Heads Up Display)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassScoreCard('SCORE', _currentScore.toString(), Colors.greenAccent),
                    _buildGlassScoreCard('BEST', highScore.toString(), Colors.amberAccent),
                  ],
                ),
              ),
              
              // Active Power-Ups Bar
              if (_activePowerUps.isNotEmpty)
                _buildActivePowerUpsBar(_activePowerUps),

              const Spacer(),

              // Mobile Controls
              if (MediaQuery.of(context).size.width < 800)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMobileControls(_game),
                ),
            ],
          ),

          // Overlays
          if (!_game.isPlaying && !_game.isGameOver && _currentScore == 0)
            _buildOverlay(
              context,
              title: 'NEON SNAKE',
              buttonText: 'INICIAR',
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
              buttonText: 'TENTAR NOVAMENTE',
              onPressed: () {
                HapticFeedback.mediumImpact();
                _game.restartGame();
                setState(() {});
              },
              isError: true,
            ),

          if (!_game.isPlaying && !_game.isGameOver && _currentScore > 0)
            _buildOverlay(
              context,
              title: 'PAUSADO',
              buttonText: 'CONTINUAR',
              onPressed: () {
                HapticFeedback.selectionClick();
                _game.startGame();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivePowerUpsBar(List<ActivePowerUp> activePowerUps) {
    final activeOnes = activePowerUps.where((p) => p.isActive).toList();
    if (activeOnes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: powerUp.type.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: powerUp.type.color.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  value: powerUp.remainingPercent,
                  strokeWidth: 2,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(powerUp.type.color),
                ),
              ),
              Text(powerUp.type.emoji, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassScoreCard(String label, String value, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
    bool isError = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.redAccent : Colors.greenAccent,
                    letterSpacing: 3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileControls(SnakeGame game) {
    return Column(
      children: [
        _buildControlButton(Icons.keyboard_arrow_up, () => game.changeDirection(Direction.up)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(Icons.keyboard_arrow_left, () => game.changeDirection(Direction.left)),
            const SizedBox(width: 50),
            _buildControlButton(Icons.keyboard_arrow_right, () => game.changeDirection(Direction.right)),
          ],
        ),
        _buildControlButton(Icons.keyboard_arrow_down, () => game.changeDirection(Direction.down)),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
