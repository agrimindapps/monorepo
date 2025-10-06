
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:core/core.dart';

part 'market_model.g.dart';

/// Market Model for Data Layer
/// 
/// Extends MarketEntity with JSON serialization and Hive persistence
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 5) // Ensure unique typeId across the app
class MarketModel extends MarketEntity {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String name;

  @override
  @HiveField(2)
  final String symbol;

  @override
  @HiveField(3)
  final MarketType type;

  @override
  @HiveField(4)
  final double currentPrice;

  @override
  @HiveField(5)
  final double previousPrice;

  @override
  @HiveField(6)
  final double changePercent;

  @override
  @HiveField(7)
  final double volume;

  @override
  @HiveField(8)
  final String currency;

  @override
  @HiveField(9)
  final String unit;

  @override
  @HiveField(10)
  final String exchange;

  @override
  @HiveField(11)
  final DateTime lastUpdated;

  @override
  @HiveField(12)
  final MarketStatus status;

  @override
  @HiveField(13)
  final List<PriceHistoryModel> history;

  @override
  @HiveField(14)
  final String? description;

  @override
  @HiveField(15)
  final String? imageUrl;

  const MarketModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercent,
    required this.volume,
    required this.currency,
    required this.unit,
    required this.exchange,
    required this.lastUpdated,
    required this.status,
    this.history = const [],
    this.description,
    this.imageUrl,
  }) : super(
          id: id,
          name: name,
          symbol: symbol,
          type: type,
          currentPrice: currentPrice,
          previousPrice: previousPrice,
          changePercent: changePercent,
          volume: volume,
          currency: currency,
          unit: unit,
          exchange: exchange,
          lastUpdated: lastUpdated,
          status: status,
          history: history,
          description: description,
          imageUrl: imageUrl,
        );

  /// Create from JSON
  factory MarketModel.fromJson(Map<String, dynamic> json) =>
      _$MarketModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$MarketModelToJson(this);

  /// Create from domain entity
  factory MarketModel.fromEntity(MarketEntity entity) {
    return MarketModel(
      id: entity.id,
      name: entity.name,
      symbol: entity.symbol,
      type: entity.type,
      currentPrice: entity.currentPrice,
      previousPrice: entity.previousPrice,
      changePercent: entity.changePercent,
      volume: entity.volume,
      currency: entity.currency,
      unit: entity.unit,
      exchange: entity.exchange,
      lastUpdated: entity.lastUpdated,
      status: entity.status,
      history: entity.history
          .map((h) => PriceHistoryModel.fromEntity(h))
          .toList(),
      description: entity.description,
      imageUrl: entity.imageUrl,
    );
  }

  /// Convert to domain entity
  MarketEntity toEntity() {
    return MarketEntity(
      id: id,
      name: name,
      symbol: symbol,
      type: type,
      currentPrice: currentPrice,
      previousPrice: previousPrice,
      changePercent: changePercent,
      volume: volume,
      currency: currency,
      unit: unit,
      exchange: exchange,
      lastUpdated: lastUpdated,
      status: status,
      history: history.map((h) => h.toEntity()).toList(),
      description: description,
      imageUrl: imageUrl,
    );
  }

  /// Copy with modifications
  MarketModel copyWith({
    String? id,
    String? name,
    String? symbol,
    MarketType? type,
    double? currentPrice,
    double? previousPrice,
    double? changePercent,
    double? volume,
    String? currency,
    String? unit,
    String? exchange,
    DateTime? lastUpdated,
    MarketStatus? status,
    List<PriceHistoryModel>? history,
    String? description,
    String? imageUrl,
  }) {
    return MarketModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      changePercent: changePercent ?? this.changePercent,
      volume: volume ?? this.volume,
      currency: currency ?? this.currency,
      unit: unit ?? this.unit,
      exchange: exchange ?? this.exchange,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      history: history ?? this.history,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Price History Model
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 6)
class PriceHistoryModel extends PriceHistory {
  @override
  @HiveField(0)
  final DateTime date;

  @override
  @HiveField(1)
  final double price;

  @override
  @HiveField(2)
  final double volume;

  @override
  @HiveField(3)
  final double high;

  @override
  @HiveField(4)
  final double low;

  @override
  @HiveField(5)
  final double open;

  @override
  @HiveField(6)
  final double close;

  const PriceHistoryModel({
    required this.date,
    required this.price,
    required this.volume,
    required this.high,
    required this.low,
    required this.open,
    required this.close,
  }) : super(
          date: date,
          price: price,
          volume: volume,
          high: high,
          low: low,
          open: open,
          close: close,
        );

  /// Create from JSON
  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PriceHistoryModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PriceHistoryModelToJson(this);

  /// Create from domain entity
  factory PriceHistoryModel.fromEntity(PriceHistory entity) {
    return PriceHistoryModel(
      date: entity.date,
      price: entity.price,
      volume: entity.volume,
      high: entity.high,
      low: entity.low,
      open: entity.open,
      close: entity.close,
    );
  }

  /// Convert to domain entity
  PriceHistory toEntity() {
    return PriceHistory(
      date: date,
      price: price,
      volume: volume,
      high: high,
      low: low,
      open: open,
      close: close,
    );
  }
}

/// Market Summary Model
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 16)
class MarketSummaryModel extends MarketSummary {
  @override
  final String marketName;

  @override
  final DateTime lastUpdated;

  @override
  final List<MarketModel> topGainers;

  @override
  final List<MarketModel> topLosers;

  @override
  final List<MarketModel> mostActive;

  @override
  final double marketIndex;

  @override
  final double marketIndexChange;

  @override
  final int totalMarkets;

  @override
  final int marketsUp;

  @override
  final int marketsDown;

  @override
  final int marketsUnchanged;

  const MarketSummaryModel({
    required this.marketName,
    required this.lastUpdated,
    required this.topGainers,
    required this.topLosers,
    required this.mostActive,
    required this.marketIndex,
    required this.marketIndexChange,
    required this.totalMarkets,
    required this.marketsUp,
    required this.marketsDown,
    required this.marketsUnchanged,
  }) : super(
          marketName: marketName,
          lastUpdated: lastUpdated,
          topGainers: topGainers,
          topLosers: topLosers,
          mostActive: mostActive,
          marketIndex: marketIndex,
          marketIndexChange: marketIndexChange,
          totalMarkets: totalMarkets,
          marketsUp: marketsUp,
          marketsDown: marketsDown,
          marketsUnchanged: marketsUnchanged,
        );

  /// Create from JSON
  factory MarketSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$MarketSummaryModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$MarketSummaryModelToJson(this);

  /// Create from domain entity
  factory MarketSummaryModel.fromEntity(MarketSummary entity) {
    return MarketSummaryModel(
      marketName: entity.marketName,
      lastUpdated: entity.lastUpdated,
      topGainers: entity.topGainers
          .map((m) => MarketModel.fromEntity(m))
          .toList(),
      topLosers: entity.topLosers
          .map((m) => MarketModel.fromEntity(m))
          .toList(),
      mostActive: entity.mostActive
          .map((m) => MarketModel.fromEntity(m))
          .toList(),
      marketIndex: entity.marketIndex,
      marketIndexChange: entity.marketIndexChange,
      totalMarkets: entity.totalMarkets,
      marketsUp: entity.marketsUp,
      marketsDown: entity.marketsDown,
      marketsUnchanged: entity.marketsUnchanged,
    );
  }

  /// Convert to domain entity
  MarketSummary toEntity() {
    return MarketSummary(
      marketName: marketName,
      lastUpdated: lastUpdated,
      topGainers: topGainers.map((m) => m.toEntity()).toList(),
      topLosers: topLosers.map((m) => m.toEntity()).toList(),
      mostActive: mostActive.map((m) => m.toEntity()).toList(),
      marketIndex: marketIndex,
      marketIndexChange: marketIndexChange,
      totalMarkets: totalMarkets,
      marketsUp: marketsUp,
      marketsDown: marketsDown,
      marketsUnchanged: marketsUnchanged,
    );
  }
}
