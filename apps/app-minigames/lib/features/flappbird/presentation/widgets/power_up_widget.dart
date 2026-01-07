import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/power_up_entity.dart';

/// Widget to display a power-up on screen
class PowerUpWidget extends StatelessWidget {
  final PowerUpEntity powerUp;

  const PowerUpWidget({
    super.key,
    required this.powerUp,
  });

  @override
  Widget build(BuildContext context) {
    if (powerUp.collected) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: powerUp.x,
      top: powerUp.y,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.2),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          width: powerUp.size,
          height: powerUp.size,
          decoration: BoxDecoration(
            color: _getPowerUpColor(powerUp.type).withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getPowerUpColor(powerUp.type),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getPowerUpColor(powerUp.type).withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              powerUp.type.emoji,
              style: TextStyle(fontSize: powerUp.size * 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.slowMotion:
        return Colors.purple;
      case PowerUpType.doublePoints:
        return Colors.amber;
      case PowerUpType.shrink:
        return Colors.green;
      case PowerUpType.ghost:
        return Colors.grey;
      case PowerUpType.magnet:
        return Colors.red;
    }
  }
}

/// Widget to display collected power-up effect
class PowerUpCollectedEffect extends StatefulWidget {
  final PowerUpType type;
  final Offset position;
  final VoidCallback onComplete;

  const PowerUpCollectedEffect({
    super.key,
    required this.type,
    required this.position,
    required this.onComplete,
  });

  @override
  State<PowerUpCollectedEffect> createState() => _PowerUpCollectedEffectState();
}

class _PowerUpCollectedEffectState extends State<PowerUpCollectedEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 30,
      top: widget.position.dy - 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                children: [
                  Text(
                    widget.type.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.type.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
