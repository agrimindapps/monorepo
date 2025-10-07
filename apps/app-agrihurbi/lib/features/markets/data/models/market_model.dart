
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:core/core.dart';

part 'market_model.g.dart';

/// Market Model for Data Layer
///
/// Extends MarketEntity with JSON serialization and Hive persistence
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 5) // Ensure unique typeId across the app
class MarketModel extends MarketEntity {
  const MarketModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String symbol,
    @HiveField(3) required MarketType type,
    @HiveField(4) required double currentPrice,
    @HiveField(5) required double previousPrice,
    @HiveField(6) required double changePercent,
    @HiveField(7) required double volume,
    @HiveField(8) required String currency,
    @HiveField(9) required String unit,
    @HiveField(10) required String exchange,
    @HiveField(11) required DateTime lastUpdated,
    @HiveField(12) required MarketStatus status,
    @HiveField(13) List<PriceHistoryModel> history = const [],
    @HiveField(14) String? description,
    @HiveField(15) String? imageUrl,
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
      id: super.id,
      name: super.name,
      symbol: super.symbol,
      type: super.type,
      currentPrice: super.currentPrice,
      previousPrice: super.previousPrice,
      changePercent: super.changePercent,
      volume: super.volume,
      currency: super.currency,
      unit: super.unit,
      exchange: super.exchange,
      lastUpdated: super.lastUpdated,
      status: super.status,
      history: super.history.map((h) => (h as PriceHistoryModel).toEntity()).toList(),
      description: super.description,
      imageUrl: super.imageUrl,
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
      id: id ?? super.id,
      name: name ?? super.name,
      symbol: symbol ?? super.symbol,
      type: type ?? super.type,
      currentPrice: currentPrice ?? super.currentPrice,
      previousPrice: previousPrice ?? super.previousPrice,
      changePercent: changePercent ?? super.changePercent,
      volume: volume ?? super.volume,
      currency: currency ?? super.currency,
      unit: unit ?? super.unit,
      exchange: exchange ?? super.exchange,
      lastUpdated: lastUpdated ?? super.lastUpdated,
      status: status ?? super.status,
      history: history ?? super.history.cast<PriceHistoryModel>(),
      description: description ?? super.description,
      imageUrl: imageUrl ?? super.imageUrl,
    );
  }
}

/// Price History Model
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 6)
class PriceHistoryModel extends PriceHistory {
  const PriceHistoryModel({
    @HiveField(0) required DateTime date,
    @HiveField(1) required double price,
    @HiveField(2) required double volume,
    @HiveField(3) required double high,
    @HiveField(4) required double low,
    @HiveField(5) required double open,
    @HiveField(6) required double close,
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
      date: super.date,
      price: super.price,
      volume: super.volume,
      high: super.high,
      low: super.low,
      open: super.open,
      close: super.close,
    );
  }
}

/// Market Summary Model
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 16)
class MarketSummaryModel extends MarketSummary {
  const MarketSummaryModel({
    required String marketName,
    required DateTime lastUpdated,
    required List<MarketModel> topGainers,
    required List<MarketModel> topLosers,
    required List<MarketModel> mostActive,
    required double marketIndex,
    required double marketIndexChange,
    required int totalMarkets,
    required int marketsUp,
    required int marketsDown,
    required int marketsUnchanged,
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
      marketName: super.marketName,
      lastUpdated: super.lastUpdated,
      topGainers: super.topGainers.map((m) => (m as MarketModel).toEntity()).toList(),
      topLosers: super.topLosers.map((m) => (m as MarketModel).toEntity()).toList(),
      mostActive: super.mostActive.map((m) => (m as MarketModel).toEntity()).toList(),
      marketIndex: super.marketIndex,
      marketIndexChange: super.marketIndexChange,
      totalMarkets: super.totalMarkets,
      marketsUp: super.marketsUp,
      marketsDown: super.marketsDown,
      marketsUnchanged: super.marketsUnchanged,
    );
  }
}
