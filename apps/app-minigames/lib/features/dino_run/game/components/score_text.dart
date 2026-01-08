import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dino_run_game.dart';

class ScoreText extends PositionComponent with HasGameReference<DinoRunGame> {
  Color _textColor = const Color(0xFF535353);
  Color _hiTextColor = const Color(0xFF757575);

  static const Color dayTextColor = Color(0xFF535353);
  static const Color dayHiTextColor = Color(0xFF757575);
  static const Color nightTextColor = Color(0xFFCCCCCC);
  static const Color nightHiTextColor = Color(0xFF999999);

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x - 20, 20);
    priority = 100;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x - 20, 20);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final score = game.score.toInt().toString().padLeft(5, '0');
    final highScore = game.highScore.toString().padLeft(5, '0');

    // High score
    if (game.highScore > 0) {
      final hiPainter = TextPainter(
        text: TextSpan(
          text: 'HI $highScore  ',
          style: TextStyle(
            color: _hiTextColor,
            fontSize: 16,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      hiPainter.layout();

      final scorePainter = TextPainter(
        text: TextSpan(
          text: score,
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      scorePainter.layout();

      final totalWidth = hiPainter.width + scorePainter.width;

      hiPainter.paint(canvas, Offset(-totalWidth, 0));
      scorePainter.paint(canvas, Offset(-scorePainter.width, 0));
    } else {
      // Just score
      final scorePainter = TextPainter(
        text: TextSpan(
          text: score,
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      scorePainter.layout();
      scorePainter.paint(canvas, Offset(-scorePainter.width, 0));
    }
  }

  void setNightMode(bool isNight) {
    _textColor = isNight ? nightTextColor : dayTextColor;
    _hiTextColor = isNight ? nightHiTextColor : dayHiTextColor;
  }
}
