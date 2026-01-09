import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mixin for Flame games to handle ESC key pause functionality
///
/// Usage:
/// ```dart
/// class MyGame extends FlameGame
///     with KeyboardEvents, EscPauseHandler {
///
///   @override
///   void restartFromPause() {
///     overlays.remove('PauseMenu');
///     reset();
///   }
/// }
/// ```
mixin EscPauseHandler on FlameGame {
  bool _isGamePaused = false;
  bool _isGameOver = false;

  bool get isGamePaused => _isGamePaused;

  /// Set this to true when game is over to prevent pause
  set isGameOver(bool value) => _isGameOver = value;

  /// Handle ESC key press - call this from your onKeyEvent
  KeyEventResult handleEscPause(
    KeyEvent event,
  ) {
    // Only handle ESC key on key down
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      togglePause();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Toggle pause state
  void togglePause() {
    // Don't pause if game is over
    if (_isGameOver) return;

    if (_isGamePaused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  /// Pause the game
  void pauseGame() {
    _isGamePaused = true;
    pauseEngine();
    overlays.add('PauseMenu');
  }

  /// Resume the game
  void resumeGame() {
    _isGamePaused = false;
    resumeEngine();
    overlays.remove('PauseMenu');
  }

  /// Restart game from pause menu - each game must implement this
  void restartFromPause();
}
