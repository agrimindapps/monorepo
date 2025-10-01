import 'package:flutter/material.dart';

import '../../../../core/widgets/semantic_widgets.dart';

/// Widget para exibir estatísticas das despesas em formato de cartões
class ExpensesStatisticsRow extends StatelessWidget {
  const ExpensesStatisticsRow({
    super.key,
    required this.statistics,
  });

  final Map<String, dynamic> statistics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticText.heading(
          'Estatísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        // Grid de estatísticas
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsivo: 2 colunas em mobile, 4 em tablet+
            final isWide = constraints.maxWidth > 600;
            final crossAxisCount = isWide ? 4 : 2;
            final childAspectRatio = isWide ? 1.2 : 1.0;
            
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
              children: [
                _buildStatCard(
                  context,
                  'Total Gasto',
                  _formatCurrency((statistics['totalAmount'] as num?)?.toDouble() ?? 0.0),
                  Icons.attach_money,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Média Mensal',
                  _formatCurrency((statistics['monthlyAverage'] as num?)?.toDouble() ?? 0.0),
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Total Registros',
                  (statistics['totalRecords'] ?? 0).toString(),
                  Icons.receipt_long,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Maior Despesa',
                  _formatCurrency((statistics['highestAmount'] as num?)?.toDouble() ?? 0.0),
                  Icons.trending_up,
                  Colors.red,
                ),
              ],
            );
          },
        ),
        
        // Estatísticas adicionais se houver dados suficientes
        if (statistics['totalRecords'] != null && (statistics['totalRecords'] as int) > 0) ...[
          const SizedBox(height: 24),
          _buildAdditionalStats(context),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return SemanticCard(
      semanticLabel: 'Estatística de $title: $value',
      semanticHint: 'Informação sobre $title das despesas',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cabeçalho com ícone
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Valor
            SemanticText(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Título
            SemanticText.label(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStats(BuildContext context) {
    final mostCommonType = statistics['mostCommonType'] as String?;
    final averagePerRecord = statistics['averagePerRecord'] as double?;
    final thisMonth = statistics['thisMonth'] as double?;
    final lastMonth = statistics['lastMonth'] as double?;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SemanticText.heading(
            'Informações Adicionais',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Tipo mais comum
          if (mostCommonType != null)
            _buildInfoRow(
              context,
              'Tipo mais comum:',
              mostCommonType,
              Icons.category,
            ),
          
          // Média por registro
          if (averagePerRecord != null)
            _buildInfoRow(
              context,
              'Média por despesa:',
              _formatCurrency(averagePerRecord),
              Icons.calculate,
            ),
          
          // Comparação mensal
          if (thisMonth != null && lastMonth != null) ...[
            const SizedBox(height: 8),
            _buildMonthlyComparison(context, thisMonth, lastMonth),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          SemanticText.label(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          SemanticText(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyComparison(BuildContext context, double thisMonth, double lastMonth) {
    final difference = thisMonth - lastMonth;
    final percentChange = lastMonth != 0 ? (difference / lastMonth * 100) : 0.0;
    final isIncrease = difference > 0;
    final isDecrease = difference < 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isIncrease 
            ? Colors.red.withValues(alpha: 0.1)
            : isDecrease 
                ? Colors.green.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isIncrease 
                ? Icons.trending_up
                : isDecrease 
                    ? Icons.trending_down
                    : Icons.trending_flat,
            color: isIncrease 
                ? Colors.red
                : isDecrease 
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SemanticText.label(
                  'Comparação mensal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SemanticText(
                  isIncrease 
                      ? '+${percentChange.toStringAsFixed(1)}% este mês'
                      : isDecrease 
                          ? '${percentChange.toStringAsFixed(1)}% este mês'
                          : 'Sem alteração',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isIncrease 
                        ? Colors.red
                        : isDecrease 
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}