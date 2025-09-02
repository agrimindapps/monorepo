import 'package:flutter/material.dart';

import '../providers/fuel_provider.dart';
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
    return Row(
      children: [
        Expanded(
          child: FuelStatCard(
            title: 'Total de Litros',
            value: '${statistics.totalLiters.toStringAsFixed(1)} L',
            icon: Icons.water_drop,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FuelStatCard(
            title: 'Gasto Total',
            value: 'R\$ ${statistics.totalCost.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FuelStatCard(
            title: 'Preço Médio',
            value: 'R\$ ${statistics.averagePrice.toStringAsFixed(2)}/L',
            icon: Icons.trending_up,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}