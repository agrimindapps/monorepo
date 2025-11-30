import 'package:flutter/material.dart';

import '../../domain/repositories/pluviometer_repository.dart';

/// Widget para exibir resumo das estatísticas
class StatisticsSummaryWidget extends StatelessWidget {
  const StatisticsSummaryWidget({
    super.key,
    required this.statistics,
  });

  final RainfallStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo do Período',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _StatCard(
              title: 'Total Acumulado',
              value: '${statistics.totalAmount.toStringAsFixed(1)} mm',
              icon: Icons.water,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Média Diária',
              value: '${statistics.averageDaily.toStringAsFixed(1)} mm',
              icon: Icons.trending_flat,
              color: Colors.teal,
            ),
            _StatCard(
              title: 'Máximo',
              value: '${statistics.maxAmount.toStringAsFixed(1)} mm',
              icon: Icons.arrow_upward,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Mínimo',
              value: statistics.minAmount > 0
                  ? '${statistics.minAmount.toStringAsFixed(1)} mm'
                  : '-- mm',
              icon: Icons.arrow_downward,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de Medições',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${statistics.measurementCount} registros',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
