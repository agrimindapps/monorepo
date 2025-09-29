import 'package:app_agrihurbi/features/news/domain/entities/commodity_price_entity.dart';
import 'package:core/core.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commodity_price_model.g.dart';

/// Commodity Price Model with Hive Serialization
/// 
/// Represents current and historical pricing data
/// for agricultural commodities and products
@HiveType(typeId: 12)
class CommodityPriceModel extends CommodityPriceEntity {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String commodityName;
  
  @HiveField(2)
  final CommodityTypeModel _type;
  
  @HiveField(3)
  final double currentPrice;
  
  @HiveField(4)
  final double previousPrice;
  
  @HiveField(5)
  final double changePercent;
  
  @HiveField(6)
  final String currency;
  
  @HiveField(7)
  final String unit;
  
  @HiveField(8)
  final String market;
  
  @HiveField(9)
  final DateTime lastUpdated;
  
  @HiveField(10)
  final List<HistoricalPriceModel> history;

  const CommodityPriceModel({
    required this.id,
    required this.commodityName,
    required CommodityTypeModel type,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercent,
    required this.currency,
    required this.unit,
    required this.market,
    required this.lastUpdated,
    this.history = const [],
  }) : _type = type,
       super(
          id: id,
          commodityName: commodityName,
          type: CommodityType.grains, // placeholder, será sobrescrito pelo getter
          currentPrice: currentPrice,
          previousPrice: previousPrice,
          changePercent: changePercent,
          currency: currency,
          unit: unit,
          market: market,
          lastUpdated: lastUpdated,
          history: history,
        );

  /// Override getter to convert model type to domain type
  @override
  CommodityType get type => _type.toDomainType();

  /// Create from Entity
  factory CommodityPriceModel.fromEntity(CommodityPriceEntity entity) {
    return CommodityPriceModel(
      id: entity.id,
      commodityName: entity.commodityName,
      type: CommodityTypeModel.fromEntity(entity.type),
      currentPrice: entity.currentPrice,
      previousPrice: entity.previousPrice,
      changePercent: entity.changePercent,
      currency: entity.currency,
      unit: entity.unit,
      market: entity.market,
      lastUpdated: entity.lastUpdated,
      history: entity.history.map((h) => HistoricalPriceModel.fromEntity(h)).toList(),
    );
  }

  /// Create from JSON (API response)
  factory CommodityPriceModel.fromJson(Map<String, dynamic> json) {
    return CommodityPriceModel(
      id: (json['id'] as String?) ?? '',
      commodityName: (json['name'] as String?) ?? '',
      type: CommodityTypeModel.fromString((json['type'] as String?) ?? 'grains'),
      currentPrice: ((json['currentPrice'] as num?) ?? 0.0).toDouble(),
      previousPrice: ((json['previousPrice'] as num?) ?? 0.0).toDouble(),
      changePercent: ((json['changePercent'] as num?) ?? 0.0).toDouble(),
      currency: (json['currency'] as String?) ?? 'BRL',
      unit: (json['unit'] as String?) ?? 'kg',
      market: (json['market'] as String?) ?? 'BMF',
      lastUpdated: DateTime.tryParse((json['lastUpdated'] as String?) ?? '') ?? DateTime.now(),
      history: (json['history'] as List<dynamic>?)
              ?.map((h) => HistoricalPriceModel.fromJson(h as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': commodityName,
      'type': type.name,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'changePercent': changePercent,
      'currency': currency,
      'unit': unit,
      'market': market,
      'lastUpdated': lastUpdated.toIso8601String(),
      'history': history.map((h) => h.toJson()).toList(),
    };
  }

  /// Copy with modifications
  CommodityPriceModel copyWith({
    String? id,
    String? commodityName,
    CommodityTypeModel? type,
    double? currentPrice,
    double? previousPrice,
    double? changePercent,
    String? currency,
    String? unit,
    String? market,
    DateTime? lastUpdated,
    List<HistoricalPriceModel>? history,
  }) {
    return CommodityPriceModel(
      id: id ?? this.id,
      commodityName: commodityName ?? this.commodityName,
      type: type ?? _type,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      changePercent: changePercent ?? this.changePercent,
      currency: currency ?? this.currency,
      unit: unit ?? this.unit,
      market: market ?? this.market,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      history: history ?? this.history,
    );
  }
}

/// Commodity Type Model with Hive Serialization
@HiveType(typeId: 13)
enum CommodityTypeModel {
  @HiveField(0)
  grains,
  
  @HiveField(1)
  livestock,
  
  @HiveField(2)
  dairy,
  
  @HiveField(3)
  vegetables,
  
  @HiveField(4)
  fruits,
  
  @HiveField(5)
  coffee,
  
  @HiveField(6)
  sugar,
  
  @HiveField(7)
  cotton,
  
  @HiveField(8)
  fertilizer;

  /// Convert to domain entity
  CommodityType toEntity() {
    switch (this) {
      case CommodityTypeModel.grains:
        return CommodityType.grains;
      case CommodityTypeModel.livestock:
        return CommodityType.livestock;
      case CommodityTypeModel.dairy:
        return CommodityType.dairy;
      case CommodityTypeModel.vegetables:
        return CommodityType.vegetables;
      case CommodityTypeModel.fruits:
        return CommodityType.fruits;
      case CommodityTypeModel.coffee:
        return CommodityType.coffee;
      case CommodityTypeModel.sugar:
        return CommodityType.sugar;
      case CommodityTypeModel.cotton:
        return CommodityType.cotton;
      case CommodityTypeModel.fertilizer:
        return CommodityType.fertilizer;
    }
  }

  /// Create from domain entity
  static CommodityTypeModel fromEntity(CommodityType type) {
    switch (type) {
      case CommodityType.grains:
        return CommodityTypeModel.grains;
      case CommodityType.livestock:
        return CommodityTypeModel.livestock;
      case CommodityType.dairy:
        return CommodityTypeModel.dairy;
      case CommodityType.vegetables:
        return CommodityTypeModel.vegetables;
      case CommodityType.fruits:
        return CommodityTypeModel.fruits;
      case CommodityType.coffee:
        return CommodityTypeModel.coffee;
      case CommodityType.sugar:
        return CommodityTypeModel.sugar;
      case CommodityType.cotton:
        return CommodityTypeModel.cotton;
      case CommodityType.fertilizer:
        return CommodityTypeModel.fertilizer;
    }
  }

  /// Create from string
  static CommodityTypeModel fromString(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'grains':
      case 'grãos':
      case 'graos':
        return CommodityTypeModel.grains;
      case 'livestock':
      case 'pecuária':
      case 'pecuaria':
        return CommodityTypeModel.livestock;
      case 'dairy':
      case 'laticínios':
      case 'laticinios':
        return CommodityTypeModel.dairy;
      case 'vegetables':
      case 'vegetais':
        return CommodityTypeModel.vegetables;
      case 'fruits':
      case 'frutas':
        return CommodityTypeModel.fruits;
      case 'coffee':
      case 'café':
      case 'cafe':
        return CommodityTypeModel.coffee;
      case 'sugar':
      case 'açúcar':
      case 'acucar':
        return CommodityTypeModel.sugar;
      case 'cotton':
      case 'algodão':
      case 'algodao':
        return CommodityTypeModel.cotton;
      case 'fertilizer':
      case 'fertilizantes':
        return CommodityTypeModel.fertilizer;
      default:
        return CommodityTypeModel.grains;
    }
  }

  String get displayName {
    switch (this) {
      case CommodityTypeModel.grains:
        return 'Grãos';
      case CommodityTypeModel.livestock:
        return 'Pecuária';
      case CommodityTypeModel.dairy:
        return 'Laticínios';
      case CommodityTypeModel.vegetables:
        return 'Vegetais';
      case CommodityTypeModel.fruits:
        return 'Frutas';
      case CommodityTypeModel.coffee:
        return 'Café';
      case CommodityTypeModel.sugar:
        return 'Açúcar';
      case CommodityTypeModel.cotton:
        return 'Algodão';
      case CommodityTypeModel.fertilizer:
        return 'Fertilizantes';
    }
  }

  /// Convert to domain entity type
  CommodityType toDomainType() {
    switch (this) {
      case CommodityTypeModel.grains:
        return CommodityType.grains;
      case CommodityTypeModel.livestock:
        return CommodityType.livestock;
      case CommodityTypeModel.dairy:
        return CommodityType.dairy;
      case CommodityTypeModel.vegetables:
        return CommodityType.vegetables;
      case CommodityTypeModel.fruits:
        return CommodityType.fruits;
      case CommodityTypeModel.coffee:
        return CommodityType.coffee;
      case CommodityTypeModel.sugar:
        return CommodityType.sugar;
      case CommodityTypeModel.cotton:
        return CommodityType.cotton;
      case CommodityTypeModel.fertilizer:
        return CommodityType.fertilizer;
    }
  }
}

/// Historical Price Model with Hive Serialization
@HiveType(typeId: 14)
class HistoricalPriceModel extends HistoricalPrice {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final double price;
  
  @HiveField(2)
  final double volume;

  const HistoricalPriceModel({
    required this.date,
    required this.price,
    this.volume = 0.0,
  }) : super(
          date: date,
          price: price,
          volume: volume,
        );

  /// Create from Entity
  factory HistoricalPriceModel.fromEntity(HistoricalPrice entity) {
    return HistoricalPriceModel(
      date: entity.date,
      price: entity.price,
      volume: entity.volume,
    );
  }

  /// Create from JSON
  factory HistoricalPriceModel.fromJson(Map<String, dynamic> json) {
    return HistoricalPriceModel(
      date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
      price: ((json['price'] as num?) ?? 0.0).toDouble(),
      volume: ((json['volume'] as num?) ?? 0.0).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'price': price,
      'volume': volume,
    };
  }
}

/// Market Summary Model with Hive Serialization
@HiveType(typeId: 15)
class MarketSummaryModel extends MarketSummaryEntity {
  @HiveField(0)
  final String marketName;
  
  @HiveField(1)
  final DateTime lastUpdated;
  
  @HiveField(2)
  final List<CommodityPriceModel> topGainers;
  
  @HiveField(3)
  final List<CommodityPriceModel> topLosers;
  
  @HiveField(4)
  final double marketIndex;
  
  @HiveField(5)
  final double marketIndexChange;

  const MarketSummaryModel({
    required this.marketName,
    required this.lastUpdated,
    required this.topGainers,
    required this.topLosers,
    required this.marketIndex,
    required this.marketIndexChange,
  }) : super(
          marketName: marketName,
          lastUpdated: lastUpdated,
          topGainers: topGainers,
          topLosers: topLosers,
          marketIndex: marketIndex,
          marketIndexChange: marketIndexChange,
        );

  /// Create from Entity
  factory MarketSummaryModel.fromEntity(MarketSummaryEntity entity) {
    return MarketSummaryModel(
      marketName: entity.marketName,
      lastUpdated: entity.lastUpdated,
      topGainers: entity.topGainers.map((c) => CommodityPriceModel.fromEntity(c)).toList(),
      topLosers: entity.topLosers.map((c) => CommodityPriceModel.fromEntity(c)).toList(),
      marketIndex: entity.marketIndex,
      marketIndexChange: entity.marketIndexChange,
    );
  }

  /// Create from JSON
  factory MarketSummaryModel.fromJson(Map<String, dynamic> json) {
    return MarketSummaryModel(
      marketName: (json['marketName'] as String?) ?? '',
      lastUpdated: DateTime.tryParse((json['lastUpdated'] as String?) ?? '') ?? DateTime.now(),
      topGainers: (json['topGainers'] as List<dynamic>?)
              ?.map((c) => CommodityPriceModel.fromJson(c as Map<String, dynamic>))
              .toList() ?? [],
      topLosers: (json['topLosers'] as List<dynamic>?)
              ?.map((c) => CommodityPriceModel.fromJson(c as Map<String, dynamic>))
              .toList() ?? [],
      marketIndex: ((json['marketIndex'] as num?) ?? 0.0).toDouble(),
      marketIndexChange: ((json['marketIndexChange'] as num?) ?? 0.0).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'marketName': marketName,
      'lastUpdated': lastUpdated.toIso8601String(),
      'topGainers': topGainers.map((c) => c.toJson()).toList(),
      'topLosers': topLosers.map((c) => c.toJson()).toList(),
      'marketIndex': marketIndex,
      'marketIndexChange': marketIndexChange,
    };
  }
}