import 'package:flutter/material.dart';

import '../services/fuel_statistics_service.dart';
import 'fuel_stat_card.dart';

/// Reusable fuel statistics row widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying fuel statistics in a row
/// Follows OCP: Open for extension via statistics data structure
class FuelStatisticsRow extends StatelessWidget {
  const FuelStatisticsRow({
    super.key,
    required this.statistics,
  });

  final FuelStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: FuelStatCard(
            title: 'Total de Litros',
            value: '${statistics.totalLiters.toStringAsFixed(1)} L',
            icon: Icons.water_drop,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FuelStatCard(
            title: 'Gasto Total',
            value: 'R\$ ${statistics.totalCost.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: colorScheme.tertiary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FuelStatCard(
            title: 'Preço Médio',
            value: 'R\$ ${statistics.averagePrice.toStringAsFixed(2)}/L',
            icon: Icons.trending_up,
            color: colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
