import 'package:flutter/material.dart';

/// Sync Status Item Widget
/// 
/// Features:
/// - Setting name and current value display
/// - Sync status indicator (synced/pending/error)
/// - Icon representation
/// - Last sync timestamp
class SyncStatusItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isSynced;
  final IconData icon;
  final DateTime? lastSyncTime;
  final VoidCallback? onTap;

  const SyncStatusItem({
    super.key,
    required this.label,
    required this.value,
    this.isSynced = true,
    required this.icon,
    this.lastSyncTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            _buildSyncIndicator(context),
          ],
        ),
      ),
    );
  }

  /// Build sync status indicator
  Widget _buildSyncIndicator(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isSynced) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 12,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          if (lastSyncTime != null) ...[
            Text(
              _formatSyncTime(lastSyncTime!),
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green,
                fontSize: 9,
              ),
            ),
          ] else ...[
            Text(
              'SYNC',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sync_problem,
            size: 12,
            color: Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            'PENDING',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.orange,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  /// Format last sync time
  String _formatSyncTime(DateTime syncTime) {
    final now = DateTime.now();
    final difference = now.difference(syncTime);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}