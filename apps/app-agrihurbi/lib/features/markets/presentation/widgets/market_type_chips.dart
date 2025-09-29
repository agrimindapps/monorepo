import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:flutter/material.dart';

/// Market Type Chips Widget
/// 
/// Displays market types as selectable chips for filtering
class MarketTypeChips extends StatelessWidget {
  final Function(MarketType) onTypeSelected;

  const MarketTypeChips({
    super.key,
    required onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: MarketType.values.length,
        itemBuilder: (context, index) {
          final type = MarketType.values[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == MarketType.values.length - 1 ? 0 : 0,
            ),
            child: ActionChip(
              avatar: Icon(
                _getIconForType(type),
                size: 18,
                color: AppTheme.primaryColor,
              ),
              label: Text(
                type.displayName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => onTypeSelected(type),
              backgroundColor: AppTheme.surfaceColor,
              side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(MarketType type) {
    switch (type) {
      case MarketType.grains:
        return Icons.grain;
      case MarketType.livestock:
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
      case MarketType.soybean:
        return Icons.grain;
      case MarketType.corn:
        return Icons.grass;
      case MarketType.beef:
        return Icons.restaurant;
    }
  }
}