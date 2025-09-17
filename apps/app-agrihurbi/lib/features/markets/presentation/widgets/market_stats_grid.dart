import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:flutter/material.dart';

/// Market Stats Grid Widget
/// 
/// Displays market statistics in a grid layout
class MarketStatsGrid extends StatelessWidget {
  final MarketEntity market;

  const MarketStatsGrid({
    super.key,
    required this.market,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          context,
          title: 'Preço Atual',
          value: market.formattedPrice,
          icon: Icons.attach_money,
          color: AppTheme.primaryColor,
        ),
        _buildStatCard(
          context,
          title: 'Variação',
          value: market.formattedChange,
          icon: market.isUp
              ? Icons.trending_up
              : market.isDown
                  ? Icons.trending_down
                  : Icons.trending_flat,
          color: market.isUp
              ? DesignTokens.marketUpColor
              : market.isDown
                  ? AppTheme.errorColor
                  : DesignTokens.textSecondaryColor,
        ),
        _buildStatCard(
          context,
          title: 'Volume',
          value: _formatVolume(market.volume),
          icon: Icons.bar_chart,
          color: AppTheme.infoColor,
        ),
        _buildStatCard(
          context,
          title: 'Status',
          value: market.status.displayName,
          icon: Icons.info_outline,
          color: _getStatusColor(market.status),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  Color _getStatusColor(MarketStatus status) {
    switch (status) {
      case MarketStatus.open:
        return DesignTokens.marketUpColor;
      case MarketStatus.closed:
        return DesignTokens.textSecondaryColor;
      case MarketStatus.suspended:
        return AppTheme.warningColor;
      case MarketStatus.preMarket:
      case MarketStatus.afterMarket:
        return AppTheme.infoColor;
    }
  }
}