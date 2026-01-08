import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dino_run_game.dart';

class Ground extends PositionComponent with HasGameReference<DinoRunGame> {
  static const double groundHeight = 80.0;

  // Ground decoration
  final List<_GroundBump> _bumps = [];
  final Random _random = Random();

  // Colors
  Color _lineColor = const Color(0xFF535353);
  Color _bumpColor = const Color(0xFF535353);

  static const Color dayLineColor = Color(0xFF535353);
  static const Color dayBumpColor = Color(0xFF535353);
  static const Color nightLineColor = Color(0xFFAAAAAA);
  static const Color nightBumpColor = Color(0xFFAAAAAA);

  @override
  Future<void> onLoad() async {
    size = Vector2(game.size.x, groundHeight);
    position = Vector2(0, game.size.y - groundHeight);
    priority = 5;

    _generateBumps();
  }

  void _generateBumps() {
    _bumps.clear();

    // Generate random ground decorations
    double x = 0;
    while (x < game.size.x + 200) {
      if (_random.nextDouble() < 0.3) {
        _bumps.add(_GroundBump(
          x: x,
          width: 2 + _random.nextDouble() * 4,
          height: 1 + _random.nextDouble() * 3,
        ));
      }
      x += 10 + _random.nextDouble() * 20;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(size.x, groundHeight);
    position = Vector2(0, size.y - groundHeight);
    _generateBumps();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!game.isPlaying || game.isGameOver) return;

    // Move bumps to simulate ground movement
    final speed = 350.0 * game.gameSpeed * dt;

    for (final bump in _bumps) {
      bump.x -= speed;
    }

    // Remove off-screen bumps and add new ones
    _bumps.removeWhere((b) => b.x < -10);

    // Add new bumps on the right
    if (_bumps.isEmpty || _bumps.last.x < game.size.x + 100) {
      final lastX = _bumps.isEmpty ? game.size.x : _bumps.last.x;

      double x = lastX + 10 + _random.nextDouble() * 20;
      while (x < game.size.x + 200) {
        if (_random.nextDouble() < 0.3) {
          _bumps.add(_GroundBump(
            x: x,
            width: 2 + _random.nextDouble() * 4,
            height: 1 + _random.nextDouble() * 3,
          ));
        }
        x += 10 + _random.nextDouble() * 20;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final linePaint = Paint()
      ..color = _lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Main ground line
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.x, 0),
      linePaint,
    );

    // Ground bumps/texture
    final bumpPaint = Paint()
      ..color = _bumpColor
      ..style = PaintingStyle.fill;

    for (final bump in _bumps) {
      canvas.drawRect(
        Rect.fromLTWH(bump.x, 4, bump.width, bump.height),
        bumpPaint,
      );
    }
  }

  void setNightMode(bool isNight) {
    _lineColor = isNight ? nightLineColor : dayLineColor;
    _bumpColor = isNight ? nightBumpColor : dayBumpColor;
  }
}

class _GroundBump {
  double x;
  final double width;
  final double height;

  _GroundBump({
    required this.x,
    required this.width,
    required this.height,
  });
}
