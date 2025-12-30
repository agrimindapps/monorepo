import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../weight/domain/entities/weight.dart';

/// Widget para exibir um item de peso na lista de registros recentes
class WeightRecordItem extends StatelessWidget {
  const WeightRecordItem({
    required this.record,
    this.previousWeight,
    this.onTap,
    super.key,
  });

  final Weight record;
  final double? previousWeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceTint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.monitor_weight,
                size: 16,
                color: theme.colorScheme.surfaceTint,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.formattedWeight,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    dateFormat.format(record.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Variation indicator
            if (previousWeight != null) _buildVariationBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVariationBadge(BuildContext context) {
    if (previousWeight == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final variation = record.weight - previousWeight!;
    final percentVariation = (variation / previousWeight!) * 100;

    Color color;
    IconData icon;

    if (variation.abs() < 0.1) {
      color = theme.colorScheme.primary;
      icon = Icons.horizontal_rule;
    } else if (variation > 0) {
      color = Colors.orange;
      icon = Icons.arrow_upward;
    } else {
      color = theme.colorScheme.error;
      icon = Icons.arrow_downward;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${percentVariation.abs().toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
