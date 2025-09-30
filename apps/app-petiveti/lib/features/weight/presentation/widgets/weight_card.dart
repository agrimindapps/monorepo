import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/weight.dart';

class WeightCard extends ConsumerWidget {
  final Weight weight;
  final Weight? previousWeight;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showAnimalInfo;
  final bool showTrend;

  const WeightCard({
    super.key,
    required this.weight,
    this.previousWeight,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showAnimalInfo = false,
    this.showTrend = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final difference = weight.calculateDifference(previousWeight);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(difference),
          width: difference?.isConcerning == true ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with weight and date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weight.formattedWeight,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: difference?.isConcerning == true 
                                ? Colors.orange[800] 
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weight.formattedDate,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Recent indicator
                  if (weight.isRecent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_new,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Recente',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              // Trend information (if available and enabled)
              if (showTrend && difference != null) ...[
                const SizedBox(height: 12),
                _buildTrendInfo(context, difference),
              ],
              
              // Body condition score
              if (weight.bodyConditionScore != null) ...[
                const SizedBox(height: 12),
                _buildBodyConditionInfo(context, weight),
              ],
              
              // Notes (if available)
              if (weight.notes != null && weight.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(127),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withAlpha(76),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: 16,
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          weight.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(179),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action buttons
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Quick stats
                    if (difference != null)
                      Expanded(
                        child: _buildQuickStats(context, difference),
                      ),
                    
                    const SizedBox(width: 12),
                    
                    // Actions menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendInfo(BuildContext context, WeightDifference difference) {
    final theme = Theme.of(context);
    final trendColor = _getTrendColor(difference.trend);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: trendColor.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: trendColor.withAlpha(76)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: trendColor.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTrendIcon(difference.trend),
              size: 16,
              color: trendColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difference.trend.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${difference.formattedDifference} (${difference.formattedPercentage}) em ${difference.daysDifference} dias',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
          if (difference.isConcerning)
            Icon(
              Icons.warning,
              size: 20,
              color: Colors.orange[700],
            ),
        ],
      ),
    );
  }

  Widget _buildBodyConditionInfo(BuildContext context, Weight weight) {
    final theme = Theme.of(context);
    final bodyCondition = weight.bodyCondition;
    final conditionColor = _getBodyConditionColor(bodyCondition);
    
    return Row(
      children: [
        Icon(
          Icons.pets,
          size: 16,
          color: theme.colorScheme.onSurface.withAlpha(153),
        ),
        const SizedBox(width: 8),
        Text(
          'Condição Corporal: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(179),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: conditionColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: conditionColor.withAlpha(76)),
          ),
          child: Text(
            '${bodyCondition.displayName} (${weight.bodyConditionScore}/9)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: conditionColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, WeightDifference difference) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variação',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              difference.trend.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              difference.formattedDifference,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getTrendColor(difference.trend),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBorderColor(WeightDifference? difference) {
    if (difference?.isConcerning == true) {
      return Colors.orange;
    }
    if (difference?.isRapidChange == true) {
      return Colors.blue;
    }
    return Colors.grey.withAlpha(76);
  }

  Color _getTrendColor(WeightTrend trend) {
    switch (trend) {
      case WeightTrend.gaining:
        return Colors.blue;
      case WeightTrend.losing:
        return Colors.orange;
      case WeightTrend.stable:
        return Colors.green;
    }
  }

  IconData _getTrendIcon(WeightTrend trend) {
    switch (trend) {
      case WeightTrend.gaining:
        return Icons.trending_up;
      case WeightTrend.losing:
        return Icons.trending_down;
      case WeightTrend.stable:
        return Icons.trending_flat;
    }
  }

  Color _getBodyConditionColor(BodyCondition condition) {
    switch (condition) {
      case BodyCondition.underweight:
        return Colors.orange;
      case BodyCondition.ideal:
        return Colors.green;
      case BodyCondition.overweight:
        return Colors.red;
      case BodyCondition.unknown:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Registro'),
        content: Text('Tem certeza que deseja excluir o registro de peso de ${weight.formattedWeight} do dia ${weight.formattedDate}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}