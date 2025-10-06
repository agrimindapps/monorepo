import 'package:app_agrihurbi/features/news/domain/entities/commodity_price_entity.dart';
import 'package:flutter/material.dart';

/// Commodity Prices Widget
/// 
/// Displays commodity prices with trend indicators and price changes
class CommodityPricesWidget extends StatelessWidget {
  final List<CommodityPriceEntity> prices;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const CommodityPricesWidget({
    super.key,
    required this.prices,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && prices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (prices.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(),
        _buildPricesList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.trending_up,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Preços não disponíveis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Não foi possível carregar os preços das commodities no momento.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onRefresh != null)
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Tentar Novamente'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricesList(BuildContext context) {
    final groupedPrices = <CommodityType, List<CommodityPriceEntity>>{};
    
    for (final price in prices) {
      groupedPrices[price.type] = groupedPrices[price.type] ?? [];
      groupedPrices[price.type]!.add(price);
    }

    return Column(
      children: groupedPrices.entries.map((entry) {
        return _buildCategorySection(context, entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    CommodityType category,
    List<CommodityPriceEntity> categoryPrices,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryHeader(context, category),
          const Divider(height: 1),
          ...categoryPrices.map((price) => _buildPriceItem(context, price)),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, CommodityType category) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(category),
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            category.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(BuildContext context, CommodityPriceEntity price) {
    return ListTile(
      title: Text(
        price.commodityName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${price.market} • ${price.unit}'),
          const SizedBox(height: 4),
          Text(
            'Atualizado: ${_formatDateTime(price.lastUpdated)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${price.currency} ${_formatPrice(price.currentPrice)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          _buildChangeIndicator(context, price),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(BuildContext context, CommodityPriceEntity price) {
    Color color;
    IconData icon;
    
    if (price.isUp) {
      color = Colors.green;
      icon = Icons.trending_up;
    } else if (price.isDown) {
      color = Colors.red;
      icon = Icons.trending_down;
    } else {
      color = Colors.grey;
      icon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            price.formattedChange,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(CommodityType category) {
    switch (category) {
      case CommodityType.grains:
        return Icons.grass;
      case CommodityType.livestock:
        return Icons.pets;
      case CommodityType.dairy:
        return Icons.local_drink;
      case CommodityType.vegetables:
        return Icons.eco;
      case CommodityType.fruits:
        return Icons.apple;
      case CommodityType.coffee:
        return Icons.coffee;
      case CommodityType.sugar:
        return Icons.cake;
      case CommodityType.cotton:
        return Icons.cloud;
      case CommodityType.fertilizer:
        return Icons.science;
    }
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    } else {
      return price.toStringAsFixed(2);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m atrás';
      } else {
        return '${difference.inHours}h atrás';
      }
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/'
             '${dateTime.month.toString().padLeft(2, '0')}/'
             '${dateTime.year}';
    }
  }
}
