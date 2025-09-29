import 'package:equatable/equatable.dart';

/// Market Entity for Agricultural Market Data
/// 
/// Represents a specific agricultural commodity market
/// with pricing, trends, and trading information
class MarketEntity extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final MarketType type;
  final double currentPrice;
  final double previousPrice;
  final double changePercent;
  final double volume;
  final String currency;
  final String unit; // kg, ton, bushel, etc.
  final String exchange; // CBOT, BMF, BM&F, etc.
  final DateTime lastUpdated;
  final MarketStatus status;
  final List<PriceHistory> history;
  final String? description;
  final String? imageUrl;

  const MarketEntity({
    required id,
    required name,
    required symbol,
    required type,
    required currentPrice,
    required previousPrice,
    required changePercent,
    required volume,
    required currency,
    required unit,
    required exchange,
    required lastUpdated,
    required status,
    history = const [],
    description,
    imageUrl,
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

  /// Get formatted current price
  String get formattedPrice {
    return '${currentPrice.toStringAsFixed(2)} $currency/$unit';
  }

  /// Get price change value
  double get priceChange => currentPrice - previousPrice;

  /// Get formatted price change value
  String get formattedPriceChange {
    final sign = priceChange > 0 ? '+' : '';
    return '$sign${priceChange.toStringAsFixed(2)} $currency';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        symbol,
        type,
        currentPrice,
        previousPrice,
        changePercent,
        volume,
        currency,
        unit,
        exchange,
        lastUpdated,
        status,
        history,
        description,
        imageUrl,
      ];
}

/// Market Types for Agricultural Products
enum MarketType {
  grains('Grãos', 'Cereais e Grãos'),
  livestock('Pecuária', 'Bovinos e Suínos'),
  dairy('Laticínios', 'Leite e Derivados'),
  vegetables('Vegetais', 'Hortaliças'),
  fruits('Frutas', 'Frutas e Cítricos'),
  coffee('Café', 'Café Arabica e Robusta'),
  sugar('Açúcar', 'Açúcar Cristal'),
  cotton('Algodão', 'Algodão em Pluma'),
  fertilizer('Fertilizantes', 'NPK e Adubos'),
  soybean('Soja', 'Soja em Grão'),
  corn('Milho', 'Milho em Grão'),
  beef('Boi Gordo', 'Boi Gordo Arrobas');

  const MarketType(displayName, description);
  final String displayName;
  final String description;
}

/// Market Status
enum MarketStatus {
  open('Aberto', 'Mercado em funcionamento'),
  closed('Fechado', 'Mercado fechado'),
  suspended('Suspenso', 'Negociações suspensas'),
  preMarket('Pré-abertura', 'Período pré-abertura'),
  afterMarket('Pós-fechamento', 'Período pós-fechamento');

  const MarketStatus(displayName, description);
  final String displayName;
  final String description;
}

/// Historical Price Data Point
class PriceHistory extends Equatable {
  final DateTime date;
  final double price;
  final double volume;
  final double high;
  final double low;
  final double open;
  final double close;

  const PriceHistory({
    required date,
    required price,
    required volume,
    required high,
    required low,
    required open,
    required close,
  });

  @override
  List<Object?> get props => [date, price, volume, high, low, open, close];
}

/// Market Summary for Dashboard
class MarketSummary extends Equatable {
  final String marketName;
  final DateTime lastUpdated;
  final List<MarketEntity> topGainers;
  final List<MarketEntity> topLosers;
  final List<MarketEntity> mostActive;
  final double marketIndex;
  final double marketIndexChange;
  final int totalMarkets;
  final int marketsUp;
  final int marketsDown;
  final int marketsUnchanged;

  const MarketSummary({
    required marketName,
    required lastUpdated,
    required topGainers,
    required topLosers,
    required mostActive,
    required marketIndex,
    required marketIndexChange,
    required totalMarkets,
    required marketsUp,
    required marketsDown,
    required marketsUnchanged,
  });

  /// Get market sentiment based on up/down ratio
  String get marketSentiment {
    if (marketsUp > marketsDown) return 'Positivo';
    if (marketsDown > marketsUp) return 'Negativo';
    return 'Neutro';
  }

  @override
  List<Object?> get props => [
        marketName,
        lastUpdated,
        topGainers,
        topLosers,
        mostActive,
        marketIndex,
        marketIndexChange,
        totalMarkets,
        marketsUp,
        marketsDown,
        marketsUnchanged,
      ];
}