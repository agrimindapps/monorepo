import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:flutter/material.dart';

/// Top Performers Section Widget
/// 
/// Shows top gainers, losers, and most active markets
class TopPerformersSection extends StatelessWidget {
  final List<MarketEntity> topGainers;
  final List<MarketEntity> topLosers;
  final List<MarketEntity> mostActive;
  final void Function(MarketEntity) onMarketTap;

  const TopPerformersSection({
    super.key,
    required this.topGainers,
    required this.topLosers,
    required this.mostActive,
    required this.onMarketTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destaques do Mercado',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Top Gainers
        _buildSection(
          context,
          title: 'Maiores Altas',
          markets: topGainers,
          icon: Icons.trending_up,
          color: DesignTokens.marketUpColor,
        ),
        
        const SizedBox(height: 16),
        
        // Top Losers
        _buildSection(
          context,
          title: 'Maiores Quedas',
          markets: topLosers,
          icon: Icons.trending_down,
          color: AppTheme.errorColor,
        ),
        
        const SizedBox(height: 16),
        
        // Most Active
        _buildSection(
          context,
          title: 'Mais Negociados',
          markets: mostActive,
          icon: Icons.show_chart,
          color: AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<MarketEntity> markets,
    required IconData icon,
    required Color color,
  }) {
    if (markets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...markets.take(3).map((market) => _buildMarketItem(context, market, color)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketItem(BuildContext context, MarketEntity market, Color color) {
    return InkWell(
      onTap: () => onMarketTap(market),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    market.symbol,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  market.formattedPrice,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  market.formattedChange,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}