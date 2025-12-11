import 'dart:async' as async;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class Cell extends PositionComponent with TapCallbacks {
  final int row;
  final int col;

  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int neighborMineCount = 0;

  final Function(Cell) onReveal;
  final Function(Cell) onFlag;

  async.Timer? _longPressTimer;

  Cell({
    required this.row,
    required this.col,
    required double cellSize,
    required this.onReveal,
    required this.onFlag,
    required Vector2 position,
  }) : super(position: position, size: Vector2.all(cellSize));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = size.toRect();
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw background
    if (isRevealed) {
      if (isMine) {
        paint.color = Colors.red;
      } else {
        paint.color = const Color(0xFFBDBDBD); // Revealed safe cell
      }
    } else {
      paint.color = const Color(0xFFC6C6C6); // Hidden cell
    }
    canvas.drawRect(rect, paint);

    // Draw border (3D effect)
    if (!isRevealed) {
      _draw3DBorder(canvas, rect);
    } else {
      // Simple border for revealed
      final borderPaint = Paint()
        ..color = Colors.grey[600]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRect(rect, borderPaint);
    }

    // Draw content
    if (isRevealed) {
      if (isMine) {
        _drawMine(canvas, rect);
      } else if (neighborMineCount > 0) {
        _drawNumber(canvas, rect);
      }
    } else if (isFlagged) {
      _drawFlag(canvas, rect);
    }
  }

  void _draw3DBorder(Canvas canvas, Rect rect) {
    final lightPaint = Paint()..color = Colors.white;
    final darkPaint = Paint()..color = Colors.grey[600]!;
    final borderSize = size.x * 0.1;

    // Top and Left (Light)
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.x, 0)
      ..lineTo(size.x - borderSize, borderSize)
      ..lineTo(borderSize, borderSize)
      ..lineTo(borderSize, size.y - borderSize)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(path1, lightPaint);

    // Bottom and Right (Dark)
    final path2 = Path()
      ..moveTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..lineTo(borderSize, size.y - borderSize)
      ..lineTo(size.x - borderSize, size.y - borderSize)
      ..lineTo(size.x - borderSize, borderSize)
      ..lineTo(size.x, 0)
      ..close();
    canvas.drawPath(path2, darkPaint);
  }

  void _drawMine(Canvas canvas, Rect rect) {
    final minePaint = Paint()..color = Colors.black;
    canvas.drawCircle(rect.center, size.x * 0.25, minePaint);
  }

  void _drawFlag(Canvas canvas, Rect rect) {
    final flagPaint = Paint()..color = Colors.red;
    final polePaint = Paint()..color = Colors.black;

    // Pole
    canvas.drawLine(
      Offset(size.x * 0.3, size.y * 0.2),
      Offset(size.x * 0.3, size.y * 0.8),
      polePaint..strokeWidth = 2,
    );

    // Flag
    final path = Path()
      ..moveTo(size.x * 0.3, size.y * 0.2)
      ..lineTo(size.x * 0.8, size.y * 0.35)
      ..lineTo(size.x * 0.3, size.y * 0.5)
      ..close();
    canvas.drawPath(path, flagPaint);
  }

  void _drawNumber(Canvas canvas, Rect rect) {
    final textSpan = TextSpan(
      text: '$neighborMineCount',
      style: TextStyle(
        color: _getNumberColor(neighborMineCount),
        fontSize: size.x * 0.6,
        fontWeight: FontWeight.bold,
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

  Color _getNumberColor(int count) {
    switch (count) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.brown;
      case 6:
        return Colors.teal;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _longPressTimer = async.Timer(const Duration(milliseconds: 500), () {
      if (!isRevealed) {
        onFlag(this);
      }
      _longPressTimer = null;
    });
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_longPressTimer != null) {
      _longPressTimer!.cancel();
      _longPressTimer = null;

      if (!isRevealed && !isFlagged) {
        onReveal(this);
      }
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }
}
