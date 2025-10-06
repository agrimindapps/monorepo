import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:flutter/material.dart';

/// Market Card Widget
/// 
/// Displays a market item in a card format with price information,
/// change indicators, and favorite functionality
class MarketCard extends StatelessWidget {
  final MarketEntity market;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const MarketCard({
    super.key,
    required this.market,
    required this.onTap,
    required this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          market.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              market.symbol,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getTypeColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                market.type.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getTypeColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppTheme.textSecondaryColor,
                    ),
                    onPressed: onFavoriteToggle,
                    tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          market.formattedPrice,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${market.unit} • ${market.exchange}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getChangeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getChangeIcon(),
                              size: 16,
                              color: _getChangeColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              market.formattedChange,
                              style: TextStyle(
                                color: _getChangeColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          market.formattedPriceChange,
                          style: TextStyle(
                            color: _getChangeColor(),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          market.status.displayName,
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  Text(
                    'Vol: ${_formatVolume(market.volume)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Text(
                    _formatTime(market.lastUpdated),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color based on price change
  Color _getChangeColor() {
    if (market.isUp) return DesignTokens.marketUpColor;
    if (market.isDown) return AppTheme.errorColor;
    return DesignTokens.textSecondaryColor;
  }

  /// Get icon based on price change
  IconData _getChangeIcon() {
    if (market.isUp) return Icons.trending_up;
    if (market.isDown) return Icons.trending_down;
    return Icons.trending_flat;
  }

  /// Get status color
  Color _getStatusColor() {
    switch (market.status) {
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

  /// Get color based on market type
  Color _getTypeColor() {
    switch (market.type) {
      case MarketType.grains:
      case MarketType.soybean:
      case MarketType.corn:
        return const Color(0xFFFFB74D); // Orange
      case MarketType.livestock:
      case MarketType.beef:
        return DesignTokens.cattleColor; // Brown
      case MarketType.dairy:
        return const Color(0xFF81C784); // Light green
      case MarketType.vegetables:
        return const Color(0xFF66BB6A); // Green
      case MarketType.fruits:
        return const Color(0xFFE57373); // Red
      case MarketType.coffee:
        return const Color(0xFF8D6E63); // Brown
      case MarketType.sugar:
        return const Color(0xFFFFB74D); // Orange
      case MarketType.cotton:
        return const Color(0xFFE0E0E0); // Light grey
      case MarketType.fertilizer:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  /// Format volume with abbreviations
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  /// Format time to show only hours and minutes
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}