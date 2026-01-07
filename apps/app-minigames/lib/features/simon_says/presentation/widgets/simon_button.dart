import 'package:flutter/material.dart';

class SimonButton extends StatelessWidget {
  final int index;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  final bool enabled;

  const SimonButton({
    super.key,
    required this.index,
    required this.color,
    required this.isActive,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive 
              ? color 
              : color.withValues(alpha: 0.3), // Using withValues as requested
          borderRadius: _getBorderRadius(index),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ]
              : [],
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(int index) {
    const double outerRadius = 100.0;
    const double innerRadius = 20.0;

    switch (index) {
      case 0: // Top Left
        return const BorderRadius.only(
          topLeft: Radius.circular(outerRadius),
          topRight: Radius.circular(innerRadius),
          bottomLeft: Radius.circular(innerRadius),
        );
      case 1: // Top Right
        return const BorderRadius.only(
          topRight: Radius.circular(outerRadius),
          topLeft: Radius.circular(innerRadius),
          bottomRight: Radius.circular(innerRadius),
        );
      case 2: // Bottom Left
        return const BorderRadius.only(
          bottomLeft: Radius.circular(outerRadius),
          topLeft: Radius.circular(innerRadius),
          bottomRight: Radius.circular(innerRadius),
        );
      case 3: // Bottom Right
        return const BorderRadius.only(
          bottomRight: Radius.circular(outerRadius),
          topRight: Radius.circular(innerRadius),
          bottomLeft: Radius.circular(innerRadius),
        );
      default:
        return BorderRadius.circular(innerRadius);
    }
  }
}
