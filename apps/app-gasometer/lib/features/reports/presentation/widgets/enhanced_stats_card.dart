import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/semantic_widgets.dart';
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
        _buildStatRow(
          context,
          label: 'Este Mês',
          value: currentMonthValue,
          percentageChange: currentMonthPercentageChange,
        ),
        const SizedBox(height: 16),
        _buildStatRow(
          context,
          label: 'Mês Anterior',
          value: previousMonthValue,
          percentageChange: previousMonthPercentageChange,
        ),
        const SizedBox(height: 16),
        _buildStatRow(
          context,
          label: 'Este Ano',
          value: currentYearValue,
          percentageChange: currentYearPercentageChange,
        ),
        const SizedBox(height: 16),
        _buildStatRow(
          context,
          label: 'Ano Anterior',
          value: previousYearValue,
          percentageChange: previousYearPercentageChange,
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String label,
    required String value,
    double? percentageChange,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SemanticText.label(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              SemanticText(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (percentageChange != null)
          PerformanceIndicator(
            percentage: percentageChange.abs(),
            isPositive: percentageChange > 0,
            showArrow: true,
          ),
      ],
    );
  }
}