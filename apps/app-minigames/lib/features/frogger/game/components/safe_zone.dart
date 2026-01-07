import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SafeZone extends PositionComponent {
  final Color color;
  
  SafeZone({
    required Vector2 position,
    required Vector2 size,
    this.color = const Color(0xFF2E7D32),
  }) : super(
    position: position,
    size: size,
  );
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = color,
    ));
  }
}
