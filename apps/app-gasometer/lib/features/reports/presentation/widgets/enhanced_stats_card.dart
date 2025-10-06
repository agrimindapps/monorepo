import 'package:flutter/material.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import 'performance_indicator.dart';

/// Enhanced statistics card with performance indicators
class EnhancedStatsCard extends StatelessWidget {
  const EnhancedStatsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.currentMonthValue,
    required this.previousMonthValue,
    required this.currentYearValue,
    required this.previousYearValue,
    this.currentMonthPercentageChange,
    this.previousMonthPercentageChange,
    this.currentYearPercentageChange,
    this.previousYearPercentageChange,
    this.isEmpty = false,
    this.onEmptyAction,
    this.emptyMessage = 'Sem dados disponíveis',
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String currentMonthValue;
  final String previousMonthValue;
  final String currentYearValue;
  final String previousYearValue;
  final double? currentMonthPercentageChange;
  final double? previousMonthPercentageChange;
  final double? currentYearPercentageChange;
  final double? previousYearPercentageChange;
  final bool isEmpty;
  final VoidCallback? onEmptyAction;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return _buildEmptyState(context);
    }
    
    return SemanticCard(
      semanticLabel: 'Estatísticas de $title',
      semanticHint: 'Mostra dados atuais e comparações de $title',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildStatsRows(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SemanticCard(
      semanticLabel: 'Estatísticas vazias de $title',
      semanticHint: 'Nenhum dado disponível para $title',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Icon(
              Icons.trending_up,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            SemanticText(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onEmptyAction != null) ...[
              const SizedBox(height: 20),
              SemanticButton(
                semanticLabel: 'Adicionar dados para $title',
                semanticHint: 'Navega para adicionar novos dados',
                type: ButtonType.outlined,
                onPressed: onEmptyAction,
                child: Text('Adicionar ${title.toLowerCase()}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        SemanticText.heading(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRows(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                label: 'Este Mês',
                value: currentMonthValue,
                percentageChange: currentMonthPercentageChange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                label: 'Mês Anterior',
                value: previousMonthValue,
                percentageChange: previousMonthPercentageChange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                label: 'Este Ano',
                value: currentYearValue,
                percentageChange: currentYearPercentageChange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                label: 'Ano Anterior',
                value: previousYearValue,
                percentageChange: previousYearPercentageChange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    double? percentageChange,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SemanticText.label(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (percentageChange != null)
                PerformanceIndicator(
                  percentage: percentageChange.abs(),
                  isPositive: percentageChange > 0,
                  showArrow: true,
                ),
            ],
          ),
          const SizedBox(height: 8),
          SemanticText(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
