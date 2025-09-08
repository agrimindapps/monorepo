import 'package:flutter/material.dart';

/// Widget para mostrar indicadores de performance com percentuais e setas
class PerformanceIndicator extends StatelessWidget {
  const PerformanceIndicator({
    super.key,
    this.percentage,
    required this.isPositive,
    this.label,
    this.showArrow = true,
  });

  final double? percentage;
  final bool isPositive;
  final String? label;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    if (percentage == null) return const SizedBox.shrink();

    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showArrow) ...[
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          '${percentage!.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 4),
          Text(
            label!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}