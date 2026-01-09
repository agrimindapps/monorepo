import 'package:flutter/material.dart';

/// Universal pause menu overlay for all games
///
/// Displays a pause screen with Continue and Restart buttons
///
/// Usage:
/// ```dart
/// // In Flame game overlayBuilderMap:
/// 'PauseMenu': (context, game) => PauseMenuOverlay(
///   onContinue: game.resumeGame,
///   onRestart: game.restartFromPause,
///   accentColor: const Color(0xFF00BCD4),
/// ),
///
/// // In Flutter game:
/// if (gameState.status == GameStatus.paused)
///   PauseMenuOverlay(
///     onContinue: () => notifier.togglePause(),
///     onRestart: () => notifier.restartGame(),
///   ),
/// ```
class PauseMenuOverlay extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final Color accentColor;

  const PauseMenuOverlay({
    required this.onContinue,
    required this.onRestart,
    this.accentColor = const Color(0xFFFFD700), // Gold default
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A).withValues(alpha: 0.95),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_outline,
                size: 64,
                color: accentColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'PAUSADO',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pressione ESC para continuar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Continuar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 220,
                child: OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reiniciar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
