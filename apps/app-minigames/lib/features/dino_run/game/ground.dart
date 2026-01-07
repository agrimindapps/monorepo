import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends PositionComponent with HasGameReference {
  static const double groundHeight = 100.0; // Same as in DinoPlayer

  @override
  Future<void> onLoad() async {
    // Fill width, set height
    size = Vector2(game.size.x, 2);
    position = Vector2(0, game.size.y - groundHeight);
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey,
    ));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(size.x, 2);
    position = Vector2(0, size.y - groundHeight);
  }
}
