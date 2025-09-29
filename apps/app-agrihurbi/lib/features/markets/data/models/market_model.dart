import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'market_model.g.dart';

/// Market Model for Data Layer
/// 
/// Extends MarketEntity with JSON serialization and Hive persistence
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 5) // Ensure unique typeId across the app
class MarketModel extends MarketEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String name;

  @HiveField(2)
  @override
  final String symbol;

  @HiveField(3)
  @override
  final MarketType type;

  @HiveField(4)
  @override
  final double currentPrice;

  @HiveField(5)
  @override
  final double previousPrice;

  @HiveField(6)
  @override
  final double changePercent;

  @HiveField(7)
  @override
  final double volume;

  @HiveField(8)
  @override
  final String currency;

  @HiveField(9)
  @override
  final String unit;

  @HiveField(10)
  @override
  final String exchange;

  @HiveField(11)
  @override
  final DateTime lastUpdated;

  @HiveField(12)
  @override
  final MarketStatus status;

  @HiveField(13)
  @override
  final List<PriceHistoryModel> history;

  @HiveField(14)
  @override
  final String? description;

  @HiveField(15)
  @override
  final String? imageUrl;

  const MarketModel({
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
      id: id ?? id,
      name: name ?? name,
      symbol: symbol ?? symbol,
      type: type ?? type,
      currentPrice: currentPrice ?? currentPrice,
      previousPrice: previousPrice ?? previousPrice,
      changePercent: changePercent ?? changePercent,
      volume: volume ?? volume,
      currency: currency ?? currency,
      unit: unit ?? unit,
      exchange: exchange ?? exchange,
      lastUpdated: lastUpdated ?? lastUpdated,
      status: status ?? status,
      history: history ?? history,
      description: description ?? description,
      imageUrl: imageUrl ?? imageUrl,
    );
  }
}

/// Price History Model
@JsonSerializable()
@HiveType(typeId: 6)
class PriceHistoryModel extends PriceHistory {
  @HiveField(0)
  @override
  final DateTime date;

  @HiveField(1)
  @override
  final double price;

  @HiveField(2)
  @override
  final double volume;

  @HiveField(3)
  @override
  final double high;

  @HiveField(4)
  @override
  final double low;

  @HiveField(5)
  @override
  final double open;

  @HiveField(6)
  @override
  final double close;

  const PriceHistoryModel({
    required date,
    required price,
    required volume,
    required high,
    required low,
    required open,
    required close,
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