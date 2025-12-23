import 'dart:math';

import 'package:flame/components.dart';

import '../flappy_bird_game.dart';
import 'pipe.dart';

class PipeManager extends Component with HasGameRef<FlappyBirdGame> {
  final Random _random = Random();
  double _timer = 0;
  final double _spawnInterval = 2.0; // Seconds between pipes

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!gameRef.isPlaying) return;
    
    _timer += dt;

    if (_timer >= _spawnInterval) {
      _timer = 0;
      _spawnPipes();
    }
  }

  void _spawnPipes() {
    final gameHeight = gameRef.size.y;
    final groundHeight = gameRef.groundHeight;
    final playAreaHeight = gameHeight - groundHeight;
    
    final pipeWidth = 60.0;
    final gapSize = 150.0;
    final minPipeHeight = 50.0;
    
    final maxPipeHeight = playAreaHeight - gapSize - minPipeHeight;
    final topPipeHeight = minPipeHeight + _random.nextDouble() * (maxPipeHeight - minPipeHeight);
    
    final bottomPipeHeight = playAreaHeight - gapSize - topPipeHeight;
    
    final pipeX = gameRef.size.x;

    // Top Pipe
    gameRef.add(Pipe(
      position: Vector2(pipeX, 0),
      size: Vector2(pipeWidth, topPipeHeight),
      isTopPipe: true,
    ));

    // Bottom Pipe
    gameRef.add(Pipe(
      position: Vector2(pipeX, topPipeHeight + gapSize),
      size: Vector2(pipeWidth, bottomPipeHeight),
      isTopPipe: false,
    ));
    
    // Add score trigger (invisible component)
    gameRef.add(ScoreTrigger(
      position: Vector2(pipeX + pipeWidth, 0),
      size: Vector2(1, playAreaHeight),
    ));
  }
  
  void reset() {
    _timer = 0;
    // Remove all pipes and score triggers
    gameRef.children.whereType<Pipe>().forEach((pipe) => pipe.removeFromParent());
    gameRef.children.whereType<ScoreTrigger>().forEach((trigger) => trigger.removeFromParent());
  }
}

class ScoreTrigger extends PositionComponent with HasGameRef<FlappyBirdGame> {
  ScoreTrigger({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);
      
  bool _triggered = false;

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!gameRef.isPlaying) return;
    
    position.x -= gameRef.gameSpeed * dt;

    if (!_triggered && position.x < gameRef.bird.position.x) {
      _triggered = true;
      gameRef.increaseScore();
    }

    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }
}
