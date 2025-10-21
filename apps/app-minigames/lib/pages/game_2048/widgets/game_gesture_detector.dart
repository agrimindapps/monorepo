// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

/// Widget responsável por detectar gestos de maneira mais precisa
/// Combina GestureDetector com detecção personalizada para melhor responsividade
class GameGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(Direction)? onSwipe;
  final bool enabled;

  const GameGestureDetector({
    super.key,
    required this.child,
    this.onSwipe,
    this.enabled = true,
  });

  @override
  State<GameGestureDetector> createState() => _GameGestureDetectorState();
}

class _GameGestureDetectorState extends State<GameGestureDetector> {
  Offset? _startPosition;
  DateTime? _startTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Detecção por drag (mais precisa)
      onPanStart: widget.enabled ? _onPanStart : null,
      onPanEnd: widget.enabled ? _onPanEnd : null,

      // Detecção por swipe (fallback)
      onHorizontalDragEnd: widget.enabled ? _onHorizontalDragEnd : null,
      onVerticalDragEnd: widget.enabled ? _onVerticalDragEnd : null,

      child: widget.child,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.localPosition;
    _startTime = DateTime.now();
  }

  void _onPanEnd(DragEndDetails details) {
    if (_startPosition == null || _startTime == null) return;

    // Calcular delta de posição (mais confiável que velocidade)
    final velocity = details.velocity.pixelsPerSecond;

    // Usar configuração personalizada para detectar direção
    final direction = GestureConfig.detectDirection(
      deltaX: velocity.dx,
      deltaY: velocity.dy,
      velocityX: velocity.dx,
      velocityY: velocity.dy,
    );

    if (direction != null) {
      widget.onSwipe?.call(direction);
    }

    _startPosition = null;
    _startTime = null;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;

    // Usar detecção mais simples como fallback
    if (velocity.dx.abs() > GestureConfig.minVelocity) {
      final direction = velocity.dx > 0 ? Direction.right : Direction.left;
      widget.onSwipe?.call(direction);
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;

    // Usar detecção mais simples como fallback
    if (velocity.dy.abs() > GestureConfig.minVelocity) {
      final direction = velocity.dy > 0 ? Direction.down : Direction.up;
      widget.onSwipe?.call(direction);
    }
  }
}
