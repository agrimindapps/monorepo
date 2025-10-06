import 'package:flutter/material.dart';

import '../../domain/entities/rain_gauge_entity.dart';

/// Widget to display rain gauges summary
class RainGaugesSummary extends StatelessWidget {
  final List<RainGaugeEntity> rainGauges;
  final bool isLoading;

  const RainGaugesSummary({
    super.key,
    required this.rainGauges,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && rainGauges.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (rainGauges.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.water_drop_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'Nenhum pluviômetro configurado',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Adicione pluviômetros para monitorar a chuva',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final operational = rainGauges.where((g) => g.isOperational).length;
    final needMaintenance = rainGauges.where((g) => g.needsMaintenance).length;
    final totalDailyRainfall = rainGauges.fold<double>(
      0.0, 
      (sum, gauge) => sum + gauge.dailyAccumulation,
    );
    final totalMonthlyRainfall = rainGauges.fold<double>(
      0.0, 
      (sum, gauge) => sum + gauge.monthlyAccumulation,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo dos Pluviômetros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Total',
                    rainGauges.length.toString(),
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Operacionais',
                    operational.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Manutenção',
                    needMaintenance.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '${totalDailyRainfall.toStringAsFixed(1)}mm',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hoje',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey.shade300,
                  ),
                  Column(
                    children: [
                      Text(
                        '${totalMonthlyRainfall.toStringAsFixed(1)}mm',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Este mês',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}