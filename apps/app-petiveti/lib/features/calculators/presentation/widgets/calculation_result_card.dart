import 'package:flutter/material.dart';

import '../../domain/entities/calculation_result.dart';

/// Widget genérico para exibir resultados de calculadoras
class CalculationResultCard extends StatelessWidget {
  const CalculationResultCard({
    super.key,
    required this.result,
  });

  final CalculationResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resultado do Cálculo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (result.summary != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  result.summary!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Valores Calculados',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...result.results.map((item) => _buildResultItem(context, item)),
            if (result.recommendations.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Recomendações',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...result.recommendations.map((rec) => _buildRecommendationItem(context, rec)),
            ],
            const SizedBox(height: 16),
            Text(
              'Calculado em: ${_formatDateTime(result.calculatedAt ?? DateTime.now())}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, ResultItem item) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${item.value}${item.unit != null ? ' ${item.unit}' : ''}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getSeverityColor(theme, item.severity),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(BuildContext context, Recommendation recommendation) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeverityColor(theme, recommendation.severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeverityColor(theme, recommendation.severity).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSeverityIcon(recommendation.severity),
                color: _getSeverityColor(theme, recommendation.severity),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getSeverityColor(theme, recommendation.severity),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.message,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(ThemeData theme, ResultSeverity? severity) {
    switch (severity) {
      case ResultSeverity.danger:
        return theme.colorScheme.error;
      case ResultSeverity.warning:
        return Colors.orange;
      case ResultSeverity.success:
        return Colors.green;
      case ResultSeverity.info:
      case null:
        return theme.colorScheme.primary;
    }
  }

  IconData _getSeverityIcon(ResultSeverity? severity) {
    switch (severity) {
      case ResultSeverity.danger:
        return Icons.error;
      case ResultSeverity.warning:
        return Icons.warning;
      case ResultSeverity.success:
        return Icons.check_circle;
      case ResultSeverity.info:
      case null:
        return Icons.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
