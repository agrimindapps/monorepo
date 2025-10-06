import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:flutter/material.dart';

/// Market Info Card Widget
/// 
/// Displays detailed market information in a card format
class MarketInfoCard extends StatelessWidget {
  final MarketEntity market;

  const MarketInfoCard({
    super.key,
    required this.market,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForType(market.type),
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        market.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${market.symbol} • ${market.type.displayName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (market.description != null) ...[
              const SizedBox(height: 16),
              Text(
                market.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(MarketType type) {
    switch (type) {
      case MarketType.grains:
      case MarketType.soybean:
      case MarketType.corn:
        return Icons.grain;
      case MarketType.livestock:
      case MarketType.beef:
        return Icons.pets;
      case MarketType.dairy:
        return Icons.local_drink;
      case MarketType.vegetables:
        return Icons.eco;
      case MarketType.fruits:
        return Icons.apple;
      case MarketType.coffee:
        return Icons.coffee;
      case MarketType.sugar:
        return Icons.cake;
      case MarketType.cotton:
        return Icons.agriculture;
      case MarketType.fertilizer:
        return Icons.scatter_plot;
    }
  }
}
