import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../maintenance/domain/entities/maintenance_entity.dart';

/// Simplified maintenance record item for activities page
/// Shows: Date | Type + Title | Cost
class MaintenanceRecordItem extends StatelessWidget {
  const MaintenanceRecordItem({
    required this.record,
    this.onTap,
    super.key,
  });

  final MaintenanceEntity record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = record.serviceDate;
    final day = date.day.toString().padLeft(2, '0');
    final weekday = DateFormat('EEE', 'pt_BR').format(date).toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Date Section (50px)
                SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        weekday,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider
                VerticalDivider(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  thickness: 1,
                  width: 24,
                ),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        record.description.isNotEmpty
                            ? record.description
                            : record.type.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(record.type.colorValue).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Color(record.type.colorValue).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          record.type.displayName,
                          style: TextStyle(
                            color: Color(record.type.colorValue),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cost Section
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${record.cost.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
