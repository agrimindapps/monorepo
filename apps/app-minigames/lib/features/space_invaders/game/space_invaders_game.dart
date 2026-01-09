import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_minigames/core/mixins/esc_pause_handler.dart';
import 'components/bullet.dart';
import 'components/invader_manager.dart';
import 'components/player_ship.dart';

class SpaceInvadersGame extends FlameGame
    with TapCallbacks, PanDetector, KeyboardEvents, HasCollisionDetection, EscPauseHandler {
  late PlayerShip player;
  late InvaderManager invaderManager;

  int score = 0;
  int lives = 3;
  bool isGameOver = false;
  bool isGameWon = false;

  @override
  Color backgroundColor() => const Color(0xFF000020);

  @override
  Future<void> onLoad() async {
    await _setupGame();
  }

  Future<void> _setupGame() async {
    // Clear existing components
    children.whereType<PlayerShip>().forEach((e) => e.removeFromParent());
    children.whereType<InvaderManager>().forEach((e) => e.removeFromParent());
    children.whereType<Bullet>().forEach((e) => e.removeFromParent());

    // Create player
    player = PlayerShip();
    add(player);

    // Create invader manager
    invaderManager = InvaderManager();
    add(invaderManager);

    // Score display
    add(
      TextComponent(
        text: 'Score: 0',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      )..priority = 10,
    );

    // Lives display
    add(
      TextComponent(
        text: 'Lives: $lives',
        position: Vector2(size.x - 100, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      )..priority = 10,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || isGameWon) return;

    // Update score display
    final scoreText = children.whereType<TextComponent>().firstOrNull;
    if (scoreText != null) {
      scoreText.text = 'Score: $score';
    }

    // Update lives display
    final livesText = children.whereType<TextComponent>().skip(1).firstOrNull;
    if (livesText != null) {
      livesText.text = 'Lives: $lives';
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver || isGameWon) return;
    player.moveBy(info.delta.global.x);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || isGameWon) return;
    player.shoot();
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Handle ESC pause first (from mixin)
    final pauseResult = handleEscPause(event);
    if (pauseResult == KeyEventResult.handled) {
      return pauseResult;
    }

    if (isGameOver || isGameWon) return KeyEventResult.ignored;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      player.moveBy(-10);
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      player.moveBy(10);
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && keysPressed.contains(LogicalKeyboardKey.space)) {
      player.shoot();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void addScore(int points) {
    score += points;
  }

  void playerHit() {
    lives--;
    if (lives <= 0) {
      gameOver();
    }
  }

  void gameOver() {
    isGameOver = true;
    super.isGameOver = true;
    overlays.add('GameOver');
  }

  void gameWon() {
    isGameWon = true;
    super.isGameOver = true;
    overlays.add('GameWon');
  }

  void checkWinCondition() {
    if (children.whereType<InvaderManager>().first.invaderCount == 0) {
      gameWon();
    }
  }

  void reset() {
    score = 0;
    lives = 3;
    isGameOver = false;
    super.isGameOver = false;
    isGameWon = false;
    overlays.remove('GameOver');
    overlays.remove('GameWon');
    _setupGame();
  }

  void restartFromPause() {
    reset();
  }
}
