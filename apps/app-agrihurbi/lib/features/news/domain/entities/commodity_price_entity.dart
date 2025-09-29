import 'package:equatable/equatable.dart';

/// Commodity Price Entity for Agricultural Market Data
/// 
/// Represents current and historical pricing data
/// for agricultural commodities and products
class CommodityPriceEntity extends Equatable {
  final String id;
  final String commodityName;
  final CommodityType type;
  final double currentPrice;
  final double previousPrice;
  final double changePercent;
  final String currency;
  final String unit; // kg, ton, bushel, etc.
  final String market; // CBOT, BMF, etc.
  final DateTime lastUpdated;
  final List<HistoricalPrice> history;

  const CommodityPriceEntity({
    required id,
    required commodityName,
    required type,
    required currentPrice,
    required previousPrice,
    required changePercent,
    required currency,
    required unit,
    required market,
    required lastUpdated,
    history = const [],
  });

  /// Check if price is trending up
  bool get isUp => changePercent > 0;

  /// Check if price is trending down
  bool get isDown => changePercent < 0;

  /// Check if price is stable
  bool get isStable => changePercent == 0;

  /// Get formatted price change
  String get formattedChange {
    final sign = isUp ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(2)}%';
  }

  @override
  List<Object?> get props => [
        id,
        commodityName,
        type,
        currentPrice,
        previousPrice,
        changePercent,
        currency,
        unit,
        market,
        lastUpdated,
        history,
      ];
}

/// Commodity Types for Agricultural Products
enum CommodityType {
  grains('Grãos'),
  livestock('Pecuária'),
  dairy('Laticínios'),
  vegetables('Vegetais'),
  fruits('Frutas'),
  coffee('Café'),
  sugar('Açúcar'),
  cotton('Algodão'),
  fertilizer('Fertilizantes');

  const CommodityType(displayName);
  final String displayName;
}

/// Historical Price Data Point
class HistoricalPrice extends Equatable {
  final DateTime date;
  final double price;
  final double volume;

  const HistoricalPrice({
    required date,
    required price,
    volume = 0.0,
  });

  @override
  List<Object?> get props => [date, price, volume];
}

/// Market Summary Entity
class MarketSummaryEntity extends Equatable {
  final String marketName;
  final DateTime lastUpdated;
  final List<CommodityPriceEntity> topGainers;
  final List<CommodityPriceEntity> topLosers;
  final double marketIndex;
  final double marketIndexChange;

  const MarketSummaryEntity({
    required marketName,
    required lastUpdated,
    required topGainers,
    required topLosers,
    required marketIndex,
    required marketIndexChange,
  });

  @override
  List<Object?> get props => [
        marketName,
        lastUpdated,
        topGainers,
        topLosers,
        marketIndex,
        marketIndexChange,
      ];
}