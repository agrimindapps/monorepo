import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TowerBackground extends PositionComponent with HasGameReference {
  TowerBackground({required Vector2 size}) : super(size: size);
  
  int _currentScore = 0;
  
  void updateScore(int score) {
    _currentScore = score;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Calculate theme based on score
    final themeIndex = (_currentScore ~/ 10) % 3;
    List<Color> colors;
    
    switch (themeIndex) {
      case 0: // Night City
        colors = const [
          Color(0xFF0F2027),
          Color(0xFF203A43),
          Color(0xFF2C5364),
        ];
        break;
      case 1: // Sunset
        colors = const [
          Color(0xFF2b5876),
          Color(0xFF4e4376),
        ];
        break;
      case 2: // Space
        colors = const [
          Color(0xFF000000),
          Color(0xFF434343),
        ];
        break;
      default:
        colors = const [
          Color(0xFF0F2027),
          Color(0xFF203A43),
          Color(0xFF2C5364),
        ];
    }
    
    // Gradient background
    final rect = Rect.fromLTWH(0, -10000, size.x, 20000); // Large vertical range
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(rect);
      
    canvas.drawRect(rect, paint);
  }
}
