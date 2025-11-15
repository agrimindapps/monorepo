import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:core/core.dart';

part 'market_model.g.dart';




/// Market Model for Data Layer
///
/// Extends MarketEntity with JSON serialization
@JsonSerializable(explicitToJson: true)
class MarketModel {
  final String id;
  final String name;
  final String symbol;
  @JsonKey(fromJson: _marketTypeFromJson, toJson: _marketTypeToJson)
  final MarketType type;
  final double currentPrice;
  final double previousPrice;
  final double changePercent;
  final double volume;
  final String currency;
  final String unit;
  final String exchange;
  final DateTime lastUpdated;
  @JsonKey(fromJson: _marketStatusFromJson, toJson: _marketStatusToJson)
  final MarketStatus status;
  final List<PriceHistoryModel> history;
  final String? description;
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
  });

  // Enum converters for JSON serialization
  static MarketType _marketTypeFromJson(String value) =>
      MarketType.values.firstWhere((e) => e.name == value);

  static String _marketTypeToJson(MarketType type) => type.name;

  static MarketStatus _marketStatusFromJson(String value) =>
      MarketStatus.values.firstWhere((e) => e.name == value);

  static String _marketStatusToJson(MarketStatus status) => status.name;

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
      history:
          entity.history.map((h) => PriceHistoryModel.fromEntity(h)).toList(),
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

  /// Check if market is going up (positive change)
  bool get isUp => changePercent > 0;

  /// Check if market is going down (negative change)
  bool get isDown => changePercent < 0;

  /// Check if market is stable (no change)
  bool get isStable => changePercent == 0;
}

/// Price History Model
@JsonSerializable(explicitToJson: true)
class PriceHistoryModel extends PriceHistory {
  const PriceHistoryModel({
    required super.date,
    required super.price,
    required super.volume,
    required super.high,
    required super.low,
    required super.open,
    required super.close,
  });

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
class MarketSummaryModel {
  final String marketName;
  final DateTime lastUpdated;
  final List<MarketModel> topGainers;
  final List<MarketModel> topLosers;
  final List<MarketModel> mostActive;
  final double marketIndex;
  final double marketIndexChange;
  final int totalMarkets;
  final int marketsUp;
  final int marketsDown;
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
  });

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
      topGainers:
          entity.topGainers.map((m) => MarketModel.fromEntity(m)).toList(),
      topLosers:
          entity.topLosers.map((m) => MarketModel.fromEntity(m)).toList(),
      mostActive:
          entity.mostActive.map((m) => MarketModel.fromEntity(m)).toList(),
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
