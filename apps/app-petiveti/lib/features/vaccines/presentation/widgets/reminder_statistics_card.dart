import 'package:flutter/material.dart';

/// Statistics card for reminder overview
///
/// **SRP**: Única responsabilidade de exibir estatísticas de lembretes
class ReminderStatisticsCard extends StatelessWidget {
  final int totalReminders;
  final int overdueCount;
  final int upcomingCount;
  final int completedCount;

  const ReminderStatisticsCard({
    super.key,
    required this.totalReminders,
    required this.overdueCount,
    required this.upcomingCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo de Lembretes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Total',
                    totalReminders,
                    Icons.notifications,
                    theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Atrasados',
                    overdueCount,
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Próximos',
                    upcomingCount,
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Completos',
                    completedCount,
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
