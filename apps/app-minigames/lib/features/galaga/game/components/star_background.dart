import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class StarBackground extends Component {
  final Vector2 screenSize;
  final List<_StarData> _stars = [];
  final Random _random = Random();
  
  StarBackground({required this.screenSize});
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create stars
    for (int i = 0; i < 100; i++) {
      _stars.add(_StarData(
        x: _random.nextDouble() * screenSize.x,
        y: _random.nextDouble() * screenSize.y,
        size: _random.nextDouble() * 2 + 0.5,
        speed: _random.nextDouble() * 50 + 20,
        brightness: _random.nextDouble() * 0.5 + 0.5,
      ));
      
      add(CircleComponent(
        radius: _stars[i].size,
        position: Vector2(_stars[i].x, _stars[i].y),
        paint: Paint()..color = Colors.white.withValues(alpha: _stars[i].brightness),
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    final circles = children.whereType<CircleComponent>().toList();
    
    for (int i = 0; i < _stars.length && i < circles.length; i++) {
      _stars[i].y += _stars[i].speed * dt;
      
      if (_stars[i].y > screenSize.y) {
        _stars[i].y = 0;
        _stars[i].x = _random.nextDouble() * screenSize.x;
      }
      
      circles[i].position = Vector2(_stars[i].x, _stars[i].y);
    }
  }
}

class _StarData {
  double x;
  double y;
  final double size;
  final double speed;
  final double brightness;
  
  _StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.brightness,
  });
}
