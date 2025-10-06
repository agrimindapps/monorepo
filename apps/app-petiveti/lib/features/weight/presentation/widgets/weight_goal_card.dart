import 'package:flutter/material.dart';

/// Widget responsible for displaying individual weight goal cards following SRP
/// 
/// Single responsibility: Display weight goal information with progress and actions
class WeightGoalCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  final VoidCallback onEdit;
  final VoidCallback onAnalytics;
  final VoidCallback onComplete;

  const WeightGoalCard({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onAnalytics,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal['progress'] as double;
    final progressColor = progress >= 0.8 
        ? Colors.green 
        : progress >= 0.5 
            ? Colors.orange 
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalHeader(theme),
            const SizedBox(height: 16),
            _buildProgressSection(theme, progress, progressColor),
            const SizedBox(height: 12),
            _buildTimelineAndActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getGoalTypeColor(goal['type'] as String).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getGoalTypeIcon(goal['type'] as String),
            color: _getGoalTypeColor(goal['type'] as String),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal['title'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                goal['animal'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPriorityColor(goal['priority'] as String).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getPriorityLabel(goal['priority'] as String),
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getPriorityColor(goal['priority'] as String),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(ThemeData theme, double progress, Color progressColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso',
                style: theme.textTheme.titleSmall,
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Atual: ${goal['currentWeight']} kg',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                'Meta: ${goal['targetWeight']} kg',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineAndActions(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'Prazo: ${_formatDate(goal['targetDate'] as DateTime)}',
          style: theme.textTheme.bodySmall,
        ),
        const Spacer(),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              iconSize: 20,
              tooltip: 'Editar meta',
            ),
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: onAnalytics,
              iconSize: 20,
              tooltip: 'Ver análise',
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: onComplete,
              iconSize: 20,
              tooltip: 'Concluir meta',
            ),
          ],
        ),
      ],
    );
  }

  Color _getGoalTypeColor(String type) {
    switch (type) {
      case 'lose':
        return Colors.red;
      case 'gain':
        return Colors.blue;
      case 'maintain':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getGoalTypeIcon(String type) {
    switch (type) {
      case 'lose':
        return Icons.trending_down;
      case 'gain':
        return Icons.trending_up;
      case 'maintain':
        return Icons.balance;
      default:
        return Icons.track_changes;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'ALTA';
      case 'medium':
        return 'MÉDIA';
      case 'low':
        return 'BAIXA';
      default:
        return 'NORMAL';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
