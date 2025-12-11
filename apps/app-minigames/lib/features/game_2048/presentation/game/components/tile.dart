import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class Tile extends PositionComponent {
  final String id;
  int value;
  final double cornerRadius;
  dynamic userData;

  Tile({
    required this.id,
    required this.value,
    required Vector2 position,
    required Vector2 size,
    this.cornerRadius = 4.0,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()..color = _getTileColor(value);
    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(rrect, paint);
    
    // Draw text
    final textSpan = TextSpan(
      text: '$value',
      style: TextStyle(
        fontSize: _getFontSize(value),
        fontWeight: FontWeight.bold,
        color: value <= 4 ? const Color(0xFF776E65) : Colors.white,
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
  
  void updateValue(int newValue) {
    value = newValue;
  }
  
  void merge() {
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
        ),
      ),
    );
  }
  
  void spawn() {
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(
          duration: 0.2,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0xFF3C3A32);
    }
  }

  double _getFontSize(int value) {
    if (value < 100) {
      return size.x * 0.5;
    } else if (value < 1000) {
      return size.x * 0.4;
    } else if (value < 10000) {
      return size.x * 0.35;
    } else {
      return size.x * 0.3;
    }
  }
}
