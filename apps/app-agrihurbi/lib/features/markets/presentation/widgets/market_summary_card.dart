import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:flutter/material.dart';

/// Market Summary Card Widget
/// 
/// Displays market overview with index, sentiment, and key statistics
class MarketSummaryCard extends StatelessWidget {
  final MarketSummary summary;

  const MarketSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.marketName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Market Index
            Row(
              children: [
                Text(
                  'Índice: ${summary.marketIndex.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getIndexChangeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIndexChangeIcon(),
                        size: 16,
                        color: _getIndexChangeColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${summary.marketIndexChange > 0 ? '+' : ''}${summary.marketIndexChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: _getIndexChangeColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Market Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    summary.totalMarkets.toString(),
                    Icons.pie_chart,
                    AppTheme.infoColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Em Alta',
                    summary.marketsUp.toString(),
                    Icons.trending_up,
                    DesignTokens.marketUpColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Em Queda',
                    summary.marketsDown.toString(),
                    Icons.trending_down,
                    AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Estáveis',
                    summary.marketsUnchanged.toString(),
                    Icons.trending_flat,
                    DesignTokens.textSecondaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Market Sentiment
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getSentimentColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getSentimentColor().withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSentimentIcon(),
                    color: _getSentimentColor(),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sentimento do Mercado',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      Text(
                        summary.marketSentiment,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getSentimentColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Last Update
            Text(
              'Atualizado em ${_formatDateTime(summary.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIndexChangeColor() {
    if (summary.marketIndexChange > 0) return DesignTokens.marketUpColor;
    if (summary.marketIndexChange < 0) return AppTheme.errorColor;
    return DesignTokens.textSecondaryColor;
  }

  IconData _getIndexChangeIcon() {
    if (summary.marketIndexChange > 0) return Icons.trending_up;
    if (summary.marketIndexChange < 0) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color _getSentimentColor() {
    switch (summary.marketSentiment) {
      case 'Positivo':
        return DesignTokens.marketUpColor;
      case 'Negativo':
        return AppTheme.errorColor;
      default:
        return DesignTokens.textSecondaryColor;
    }
  }

  IconData _getSentimentIcon() {
    switch (summary.marketSentiment) {
      case 'Positivo':
        return Icons.sentiment_satisfied;
      case 'Negativo':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}