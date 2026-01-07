import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../frogger_game.dart';

class Goal extends PositionComponent with HasGameReference<FroggerGame> {
  final int index;
  bool isReached = false;
  
  Goal({
    required Vector2 position,
    required Vector2 size,
    required this.index,
  }) : super(
    position: position,
    size: size,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateVisual();
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
  
  void _updateVisual() {
    removeAll(children.whereType<RectangleComponent>());
    
    final color = game.goalsReached[index]
        ? const Color(0xFF4CAF50)
        : const Color(0xFF1B5E20);
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = color,
    ));
    
    // Lily pad appearance
    add(CircleComponent(
      radius: size.x * 0.4,
      position: Vector2(size.x / 2, size.y / 2),
      paint: Paint()..color = const Color(0xFF388E3C),
      anchor: Anchor.center,
    ));
    
    if (game.goalsReached[index]) {
      // Show frog icon
      add(CircleComponent(
        radius: size.x * 0.25,
        position: Vector2(size.x / 2, size.y / 2),
        paint: Paint()..color = const Color(0xFF4CAF50),
        anchor: Anchor.center,
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (isReached != game.goalsReached[index]) {
      isReached = game.goalsReached[index];
      _updateVisual();
    }
  }
}
