// Flutter imports:
import 'package:flutter/material.dart';

class CommodityModel {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double previousPrice;
  final String unit;
  final String category;
  final DateTime lastUpdate;
  final String exchange;
  final CommodityPriceHistory history;
  final Map<String, dynamic> metadata;

  CommodityModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.previousPrice,
    required this.unit,
    required this.category,
    required this.lastUpdate,
    required this.exchange,
    required this.history,
    this.metadata = const {},
  });

  double get changeValue => currentPrice - previousPrice;
  double get changePercent => previousPrice != 0
      ? ((currentPrice - previousPrice) / previousPrice) * 100
      : 0;
  bool get isUp => changeValue > 0;
  bool get isDown => changeValue < 0;
  bool get isStable => changeValue == 0;

  String get formattedPrice =>
      'R\$ ${currentPrice.toStringAsFixed(2).replaceAll('.', ',')}';
  String get formattedChange =>
      '${isUp ? '+' : ''}${changePercent.toStringAsFixed(2).replaceAll('.', ',')}%';
  String get formattedChangeValue =>
      '${isUp ? '+' : ''}R\$ ${changeValue.abs().toStringAsFixed(2).replaceAll('.', ',')}';

  String get trendIcon {
    if (isUp) return '📈';
    if (isDown) return '📉';
    return '➖';
  }

  Color get trendColor {
    if (isUp) return const Color(0xFF4CAF50);
    if (isDown) return const Color(0xFFF44336);
    return const Color(0xFF9E9E9E);
  }

  factory CommodityModel.fromJson(Map<String, dynamic> json) {
    return CommodityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      currentPrice: json['currentPrice']?.toDouble() ?? 0.0,
      previousPrice: json['previousPrice']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      category: json['category'] ?? '',
      lastUpdate: DateTime.tryParse(json['lastUpdate'] ?? '') ?? DateTime.now(),
      exchange: json['exchange'] ?? '',
      history: CommodityPriceHistory.fromJson(json['history'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'unit': unit,
      'category': category,
      'lastUpdate': lastUpdate.toIso8601String(),
      'exchange': exchange,
      'history': history.toJson(),
      'metadata': metadata,
    };
  }

  CommodityModel copyWith({
    String? id,
    String? name,
    String? symbol,
    double? currentPrice,
    double? previousPrice,
    String? unit,
    String? category,
    DateTime? lastUpdate,
    String? exchange,
    CommodityPriceHistory? history,
    Map<String, dynamic>? metadata,
  }) {
    return CommodityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      exchange: exchange ?? this.exchange,
      history: history ?? this.history,
      metadata: metadata ?? this.metadata,
    );
  }
}

class CommodityPriceHistory {
  final List<CommodityPricePoint> daily;
  final List<CommodityPricePoint> weekly;
  final List<CommodityPricePoint> monthly;
  final CommodityStats stats;

  CommodityPriceHistory({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.stats,
  });

  factory CommodityPriceHistory.fromJson(Map<String, dynamic> json) {
    return CommodityPriceHistory(
      daily: (json['daily'] as List?)
              ?.map((e) => CommodityPricePoint.fromJson(e))
              .toList() ??
          [],
      weekly: (json['weekly'] as List?)
              ?.map((e) => CommodityPricePoint.fromJson(e))
              .toList() ??
          [],
      monthly: (json['monthly'] as List?)
              ?.map((e) => CommodityPricePoint.fromJson(e))
              .toList() ??
          [],
      stats: CommodityStats.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily': daily.map((e) => e.toJson()).toList(),
      'weekly': weekly.map((e) => e.toJson()).toList(),
      'monthly': monthly.map((e) => e.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }

  factory CommodityPriceHistory.empty() {
    return CommodityPriceHistory(
      daily: [],
      weekly: [],
      monthly: [],
      stats: CommodityStats.empty(),
    );
  }
}

class CommodityPricePoint {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CommodityPricePoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CommodityPricePoint.fromJson(Map<String, dynamic> json) {
    return CommodityPricePoint(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      open: json['open']?.toDouble() ?? 0.0,
      high: json['high']?.toDouble() ?? 0.0,
      low: json['low']?.toDouble() ?? 0.0,
      close: json['close']?.toDouble() ?? 0.0,
      volume: json['volume']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
}

class CommodityStats {
  final double high52Week;
  final double low52Week;
  final double average30Day;
  final double volatility;
  final double volume30Day;

  CommodityStats({
    required this.high52Week,
    required this.low52Week,
    required this.average30Day,
    required this.volatility,
    required this.volume30Day,
  });

  factory CommodityStats.fromJson(Map<String, dynamic> json) {
    return CommodityStats(
      high52Week: json['high52Week']?.toDouble() ?? 0.0,
      low52Week: json['low52Week']?.toDouble() ?? 0.0,
      average30Day: json['average30Day']?.toDouble() ?? 0.0,
      volatility: json['volatility']?.toDouble() ?? 0.0,
      volume30Day: json['volume30Day']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'high52Week': high52Week,
      'low52Week': low52Week,
      'average30Day': average30Day,
      'volatility': volatility,
      'volume30Day': volume30Day,
    };
  }

  factory CommodityStats.empty() {
    return CommodityStats(
      high52Week: 0.0,
      low52Week: 0.0,
      average30Day: 0.0,
      volatility: 0.0,
      volume30Day: 0.0,
    );
  }
}

class CommodityCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> commodityIds;

  CommodityCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.commodityIds,
  });

  factory CommodityCategory.fromJson(Map<String, dynamic> json) {
    return CommodityCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      commodityIds: List<String>.from(json['commodityIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'commodityIds': commodityIds,
    };
  }
}

class CommodityMarketStatus {
  final bool isOpen;
  final String status;
  final DateTime? nextOpen;
  final DateTime? nextClose;
  final String timezone;

  CommodityMarketStatus({
    required this.isOpen,
    required this.status,
    this.nextOpen,
    this.nextClose,
    required this.timezone,
  });

  factory CommodityMarketStatus.fromJson(Map<String, dynamic> json) {
    return CommodityMarketStatus(
      isOpen: json['isOpen'] ?? false,
      status: json['status'] ?? '',
      nextOpen:
          json['nextOpen'] != null ? DateTime.tryParse(json['nextOpen']) : null,
      nextClose: json['nextClose'] != null
          ? DateTime.tryParse(json['nextClose'])
          : null,
      timezone: json['timezone'] ?? 'America/Sao_Paulo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOpen': isOpen,
      'status': status,
      'nextOpen': nextOpen?.toIso8601String(),
      'nextClose': nextClose?.toIso8601String(),
      'timezone': timezone,
    };
  }
}
