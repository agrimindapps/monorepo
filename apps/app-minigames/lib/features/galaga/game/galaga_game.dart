import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_minigames/core/mixins/esc_pause_handler.dart';
import 'components/player_ship.dart';
import 'components/bullet.dart';
import 'components/enemy_manager.dart';
import 'components/star_background.dart';

class GalagaGame extends FlameGame with KeyboardEvents, TapCallbacks, DragCallbacks, HasCollisionDetection, EscPauseHandler {
  late GalagaPlayerShip player;
  late EnemyManager enemyManager;
  late TextComponent scoreText;
  late TextComponent livesText;
  late TextComponent waveText;
  
  int score = 0;
  int lives = 3;
  int wave = 1;
  bool isGameOver = false;
  double shootCooldown = 0;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF000011),
    ));
    
    // Stars
    add(StarBackground(screenSize: size));
    
    _setupGame();
    _setupUI();
  }
  
  void _setupGame() {
    // Player
    player = GalagaPlayerShip(
      position: Vector2(size.x / 2, size.y - 80),
    );
    add(player);
    
    // Enemy manager
    enemyManager = EnemyManager(
      screenSize: size,
      wave: wave,
    );
    add(enemyManager);
  }
  
  void _setupUI() {
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);
    
    livesText = TextComponent(
      text: '❤️ x $lives',
      position: Vector2(size.x - 80, 10),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(livesText);
    
    waveText = TextComponent(
      text: 'Wave $wave',
      position: Vector2(size.x / 2, 10),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 14,
        ),
      ),
    );
    add(waveText);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (isGameOver) return;
    
    shootCooldown -= dt;
    
    // Check wave completion
    if (enemyManager.allEnemiesDefeated) {
      nextWave();
    }
  }
  
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Handle ESC pause first (from mixin)
    final pauseResult = handleEscPause(event);
    if (pauseResult == KeyEventResult.handled) {
      return pauseResult;
    }

    if (isGameOver) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
        restartGame();
      }
      return KeyEventResult.handled;
    }

    // Movement
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      player.moveLeft();
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      player.moveRight(size.x);
    } else {
      player.stopMoving();
    }

    // Shooting
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      shoot();
    }

    return KeyEventResult.handled;
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) {
      restartGame();
      return;
    }
    shoot();
  }
  
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver) return;
    
    player.position.x += event.localDelta.x;
    player.position.x = player.position.x.clamp(20, size.x - 20);
  }
  
  void shoot() {
    if (shootCooldown > 0) return;
    
    add(PlayerBullet(
      position: player.position + Vector2(0, -20),
    ));
    
    shootCooldown = 0.25;
  }
  
  void addScore(int points) {
    score += points;
    scoreText.text = 'Score: $score';
  }
  
  void playerHit() {
    lives--;
    livesText.text = '❤️ x $lives';
    
    if (lives <= 0) {
      gameOver();
    } else {
      // Brief invincibility
      player.setInvincible(2.0);
    }
  }
  
  void nextWave() {
    wave++;
    waveText.text = 'Wave $wave';
    
    // Show wave message
    final waveMessage = TextComponent(
      text: 'Wave $wave',
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(waveMessage);
    
    Future.delayed(const Duration(seconds: 2), () {
      waveMessage.removeFromParent();
      enemyManager.removeFromParent();
      enemyManager = EnemyManager(
        screenSize: size,
        wave: wave,
      );
      add(enemyManager);
    });
  }
  
  void gameOver() {
    isGameOver = true;
    super.isGameOver = true;
    
    add(RectangleComponent(
      position: Vector2(size.x / 2 - 120, size.y / 2 - 80),
      size: Vector2(240, 160),
      paint: Paint()..color = Colors.black87,
    ));
    
    add(TextComponent(
      text: 'GAME OVER',
      position: Vector2(size.x / 2, size.y / 2 - 40),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
    
    add(TextComponent(
      text: 'Score: $score',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    ));
    
    add(TextComponent(
      text: 'Wave: $wave',
      position: Vector2(size.x / 2, size.y / 2 + 25),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 16,
        ),
      ),
    ));
    
    add(TextComponent(
      text: 'Tap to restart',
      position: Vector2(size.x / 2, size.y / 2 + 55),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    ));
  }
  
  void restartGame() {
    removeAll(children);
    score = 0;
    lives = 3;
    wave = 1;
    isGameOver = false;
    super.isGameOver = false;
    shootCooldown = 0;

    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF000011),
    ));
    add(StarBackground(screenSize: size));

    _setupGame();
    _setupUI();
  }

  void restartFromPause() {
    restartGame();
  }
}
