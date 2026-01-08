import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dino_run_game.dart';

class ParallaxBackground extends Component with HasGameReference<DinoRunGame> {
  final List<_Mountain> _mountains = [];
  final List<_Star> _stars = [];
  final Random _random = Random();

  bool _isNight = false;
  double _moonX = 0;

  // Colors
  Color _mountainColor = const Color(0xFFE8E8E8);
  static const Color dayMountainColor = Color(0xFFE8E8E8);
  static const Color nightMountainColor = Color(0xFF2A2A4A);

  @override
  Future<void> onLoad() async {
    priority = 0; // Lowest priority = drawn first (background)
    _generateMountains();
    _generateStars();
    _moonX = game.size.x * 0.8;
  }

  void _generateMountains() {
    _mountains.clear();

    double x = -50;
    while (x < game.size.x + 200) {
      _mountains.add(_Mountain(
        x: x,
        width: 80 + _random.nextDouble() * 120,
        height: 40 + _random.nextDouble() * 60,
        layer: _random.nextInt(2), // 0 = back, 1 = front
      ));
      x += 60 + _random.nextDouble() * 80;
    }
  }

  void _generateStars() {
    _stars.clear();

    for (int i = 0; i < 50; i++) {
      _stars.add(_Star(
        x: _random.nextDouble() * game.size.x,
        y: _random.nextDouble() * (game.size.y * 0.5),
        size: 1 + _random.nextDouble() * 2,
        twinkleOffset: _random.nextDouble() * 3.14,
      ));
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _generateMountains();
    _generateStars();
  }

  @override
  void update(double dt) {
    if (!game.isPlaying || game.isGameOver) return;

    final baseSpeed = 350.0 * game.gameSpeed * dt;

    // Move mountains (parallax - back layer slower)
    for (final mountain in _mountains) {
      final speedMultiplier = mountain.layer == 0 ? 0.1 : 0.2;
      mountain.x -= baseSpeed * speedMultiplier;
    }

    // Remove and regenerate off-screen mountains
    _mountains.removeWhere((m) => m.x + m.width < -50);

    if (_mountains.isEmpty || _mountains.last.x < game.size.x + 100) {
      final lastX =
          _mountains.isEmpty ? game.size.x : _mountains.last.x + _mountains.last.width;

      double x = lastX + 20;
      while (x < game.size.x + 300) {
        _mountains.add(_Mountain(
          x: x,
          width: 80 + _random.nextDouble() * 120,
          height: 40 + _random.nextDouble() * 60,
          layer: _random.nextInt(2),
        ));
        x += 60 + _random.nextDouble() * 80;
      }
    }

    // Move moon slowly
    if (_isNight) {
      _moonX -= baseSpeed * 0.02;
      if (_moonX < -50) {
        _moonX = game.size.x + 50;
      }
    }

    // Lerp mountain color
    final targetColor = _isNight ? nightMountainColor : dayMountainColor;
    _mountainColor = Color.lerp(_mountainColor, targetColor, dt * 2)!;
  }

  @override
  void render(Canvas canvas) {
    // Draw stars (only at night)
    if (_isNight) {
      _renderStars(canvas);
      _renderMoon(canvas);
    }

    // Draw mountains (back layer first)
    for (final mountain in _mountains.where((m) => m.layer == 0)) {
      _renderMountain(canvas, mountain, 0.5);
    }

    for (final mountain in _mountains.where((m) => m.layer == 1)) {
      _renderMountain(canvas, mountain, 0.7);
    }
  }

  void _renderStars(Canvas canvas) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (final star in _stars) {
      // Twinkle effect
      final twinkle = (sin(time * 2 + star.twinkleOffset) + 1) / 2;
      final opacity = 0.3 + twinkle * 0.7;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(star.x, star.y),
        star.size,
        paint,
      );
    }
  }

  void _renderMoon(Canvas canvas) {
    // Moon
    final moonPaint = Paint()..color = const Color(0xFFF5F5DC);
    canvas.drawCircle(
      Offset(_moonX, 50),
      25,
      moonPaint,
    );

    // Moon craters (subtle)
    final craterPaint = Paint()..color = const Color(0xFFE8E8C8);
    canvas.drawCircle(Offset(_moonX - 8, 45), 5, craterPaint);
    canvas.drawCircle(Offset(_moonX + 6, 55), 3, craterPaint);
    canvas.drawCircle(Offset(_moonX + 2, 42), 4, craterPaint);
  }

  void _renderMountain(Canvas canvas, _Mountain mountain, double opacity) {
    final paint = Paint()
      ..color = _mountainColor.withValues(alpha: opacity);

    final path = Path()
      ..moveTo(mountain.x, game.size.y - 80) // Ground level
      ..lineTo(mountain.x + mountain.width / 2, game.size.y - 80 - mountain.height)
      ..lineTo(mountain.x + mountain.width, game.size.y - 80)
      ..close();

    canvas.drawPath(path, paint);
  }

  void setNightMode(bool isNight) {
    _isNight = isNight;
  }
}

class _Mountain {
  double x;
  final double width;
  final double height;
  final int layer;

  _Mountain({
    required this.x,
    required this.width,
    required this.height,
    required this.layer,
  });
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double twinkleOffset;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleOffset,
  });
}
