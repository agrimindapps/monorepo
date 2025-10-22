import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/tile_entity.dart';

/// Widget that displays a single tile with animations
class TileWidget extends StatefulWidget {
  final TileEntity tile;
  final double cellSize;
  final double spacing;

  const TileWidget({
    super.key,
    required this.tile,
    required this.cellSize,
    required this.spacing,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Trigger spawn animation if tile is new
    if (widget.tile.animationType == AnimationType.spawn) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger merge animation
    if (widget.tile.animationType == AnimationType.merge) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.tile.position;
    final left = widget.spacing + (position.col * (widget.cellSize + widget.spacing));
    final top = widget.spacing + (position.row * (widget.cellSize + widget.spacing));

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      left: left,
      top: top,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.cellSize,
          height: widget.cellSize,
          decoration: BoxDecoration(
            color: _getTileColor(widget.tile.value),
            borderRadius: BorderRadius.circular(4),
            boxShadow: widget.tile.animationType == AnimationType.merge
                ? [
                    BoxShadow(
                      color: _getTileColor(widget.tile.value).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '${widget.tile.value}',
              style: TextStyle(
                fontSize: _getFontSize(widget.tile.value),
                fontWeight: FontWeight.bold,
                color: widget.tile.value <= 4
                    ? const Color(0xFF776E65)
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns color based on tile value
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

  /// Returns font size based on tile value (smaller for larger numbers)
  double _getFontSize(int value) {
    if (value < 100) {
      return 32;
    } else if (value < 1000) {
      return 28;
    } else if (value < 10000) {
      return 24;
    } else {
      return 20;
    }
  }
}
