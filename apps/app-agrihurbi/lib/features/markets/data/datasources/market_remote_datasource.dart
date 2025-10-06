import 'package:app_agrihurbi/core/network/dio_client.dart';
import 'package:app_agrihurbi/features/markets/data/models/market_model.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_filter_entity.dart';
import 'package:injectable/injectable.dart';

/// Abstract Market Remote DataSource
abstract class MarketRemoteDataSource {
  /// Get markets from API
  Future<List<MarketModel>> getMarkets({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
  });

  /// Get market by ID from API
  Future<MarketModel> getMarketById(String id);

  /// Search markets in API
  Future<List<MarketModel>> searchMarkets({
    required String query,
    MarketFilter? filter,
    int limit = 20,
  });

  /// Get markets by type from API
  Future<List<MarketModel>> getMarketsByType({
    required MarketType type,
    int limit = 20,
  });

  /// Get market summary from API
  Future<MarketSummaryModel> getMarketSummary();

  /// Get top gainers from API
  Future<List<MarketModel>> getTopGainers({
    int limit = 10,
    MarketType? type,
  });

  /// Get top losers from API
  Future<List<MarketModel>> getTopLosers({
    int limit = 10,
    MarketType? type,
  });

  /// Get most active markets from API
  Future<List<MarketModel>> getMostActive({
    int limit = 10,
    MarketType? type,
  });

  /// Get market price history from API
  Future<List<PriceHistoryModel>> getMarketHistory({
    required String marketId,
    required DateTime startDate,
    required DateTime endDate,
    String interval = '1d',
  });
}

/// Implementation of Market Remote DataSource using API
@Injectable(as: MarketRemoteDataSource)
@Environment('prod')
class MarketRemoteDataSourceImpl implements MarketRemoteDataSource {
  final DioClient _dioClient;

  MarketRemoteDataSourceImpl(this._dioClient);

  static const String _baseEndpoint = '/api/v1/markets';

  @override
  Future<List<MarketModel>> getMarkets({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (filter != null) {
      if (filter.types?.isNotEmpty == true) {
        queryParameters['types'] = filter.types!.map((t) => t.name).join(',');
      }
      if (filter.exchanges?.isNotEmpty == true) {
        queryParameters['exchanges'] = filter.exchanges!.join(',');
      }
      if (filter.searchQuery?.isNotEmpty == true) {
        queryParameters['search'] = filter.searchQuery;
      }
      if (filter.priceRange != null) {
        if (filter.priceRange!.minPrice != null) {
          queryParameters['min_price'] = filter.priceRange!.minPrice;
        }
        if (filter.priceRange!.maxPrice != null) {
          queryParameters['max_price'] = filter.priceRange!.maxPrice;
        }
      }
      queryParameters['sort_by'] = filter.sortBy.name;
      queryParameters['sort_order'] = filter.sortOrder.name;
    }

    final response = await _dioClient.get(
      _baseEndpoint,
      queryParameters: queryParameters,
    );

    final data = response.data as Map<String, dynamic>;
    final marketsJson = data['markets'] as List<dynamic>;

    return marketsJson
        .map((json) => MarketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MarketModel> getMarketById(String id) async {
    final response = await _dioClient.get('$_baseEndpoint/$id');
    
    final data = response.data as Map<String, dynamic>;
    return MarketModel.fromJson(data['market'] as Map<String, dynamic>);
  }

  @override
  Future<List<MarketModel>> searchMarkets({
    required String query,
    MarketFilter? filter,
    int limit = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'q': query,
      'limit': limit,
    };
    if (filter != null) {
      if (filter.types?.isNotEmpty == true) {
        queryParameters['types'] = filter.types!.map((t) => t.name).join(',');
      }
      if (filter.exchanges?.isNotEmpty == true) {
        queryParameters['exchanges'] = filter.exchanges!.join(',');
      }
    }

    final response = await _dioClient.get(
      '$_baseEndpoint/search',
      queryParameters: queryParameters,
    );

    final data = response.data as Map<String, dynamic>;
    final marketsJson = data['results'] as List<dynamic>;

    return marketsJson
        .map((json) => MarketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MarketModel>> getMarketsByType({
    required MarketType type,
    int limit = 20,
  }) async {
    final response = await _dioClient.get(
      '$_baseEndpoint/type/${type.name}',
      queryParameters: {'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final marketsJson = data['markets'] as List<dynamic>;

    return marketsJson
        .map((json) => MarketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MarketSummaryModel> getMarketSummary() async {
    final response = await _dioClient.get('$_baseEndpoint/summary');
    
    final data = response.data as Map<String, dynamic>;
    return MarketSummaryModel.fromJson(data['summary'] as Map<String, dynamic>);
  }

  @override
  Future<List<MarketModel>> getTopGainers({
    int limit = 10,
    MarketType? type,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit};
    if (type != null) {
      queryParameters['type'] = type.name;
    }

    final response = await _dioClient.get(
      '$_baseEndpoint/top/gainers',
      queryParameters: queryParameters,
    );

    final data = response.data as Map<String, dynamic>;
    final marketsJson = data['markets'] as List<dynamic>;

    return marketsJson
        .map((json) => MarketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MarketModel>> getTopLosers({
    int limit = 10,
    MarketType? type,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit};
    if (type != null) {
      queryParameters['type'] = type.name;
    }

    final response = await _dioClient.get(
      '$_baseEndpoint/top/losers',
      queryParameters: queryParameters,
    );

    final data = response.data as Map<String, dynamic>;
    final marketsJson = data['markets'] as List<dynamic>;

    return marketsJson
        .map((json) => MarketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MarketModel>> getMostActive({
    int limit = 10,
    MarketType? type,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit};
    if (type != null) {
      queryParameters['type'] = type.name;
    }

    final response = await _dioClient.get(
      '$_baseEndpoint/top/active',
      queryParameters: queryParameters,
    );

    final data = response.data as Map<String, dynamic>;
    final marketsJson = data['markets'] as List<dynamic>;

    return marketsJson
        .map((json) => MarketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PriceHistoryModel>> getMarketHistory({
    required String marketId,
    required DateTime startDate,
    required DateTime endDate,
    String interval = '1d',
  }) async {
    final queryParameters = <String, dynamic>{
      'start': startDate.toIso8601String(),
      'end': endDate.toIso8601String(),
      'interval': interval,
    };

    final response = await _dioClient.get(
      '$_baseEndpoint/$marketId/history',
      queryParameters: queryParameters,
    );

    final data = response.data as Map<String, dynamic>;
    final historyJson = data['history'] as List<dynamic>;

    return historyJson
        .map((json) => PriceHistoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Mock implementation for development/testing
@Injectable(as: MarketRemoteDataSource)
@Environment('dev') // Use this annotation for development environment
class MarketRemoteDataSourceMock implements MarketRemoteDataSource {
  
  /// Generate mock market data
  List<MarketModel> _generateMockMarkets() {
    return [
      MarketModel(
        id: 'soja_spot',
        name: 'Soja em Grão',
        symbol: 'SOJA',
        type: MarketType.soybean,
        currentPrice: 158.50,
        previousPrice: 155.20,
        changePercent: 2.13,
        volume: 45000,
        currency: 'BRL',
        unit: 'sc/60kg',
        exchange: 'BMF',
        lastUpdated: DateTime.now(),
        status: MarketStatus.open,
        description: 'Soja em grão para entrega imediata',
        imageUrl: 'https://example.com/soja.jpg',
      ),
      MarketModel(
        id: 'milho_spot',
        name: 'Milho em Grão',
        symbol: 'MILHO',
        type: MarketType.corn,
        currentPrice: 89.75,
        previousPrice: 92.30,
        changePercent: -2.76,
        volume: 32000,
        currency: 'BRL',
        unit: 'sc/60kg',
        exchange: 'BMF',
        lastUpdated: DateTime.now(),
        status: MarketStatus.open,
        description: 'Milho em grão para entrega imediata',
      ),
      MarketModel(
        id: 'boi_gordo',
        name: 'Boi Gordo',
        symbol: 'BOI',
        type: MarketType.beef,
        currentPrice: 295.80,
        previousPrice: 293.50,
        changePercent: 0.78,
        volume: 15000,
        currency: 'BRL',
        unit: 'arroba',
        exchange: 'BMF',
        lastUpdated: DateTime.now(),
        status: MarketStatus.open,
        description: 'Boi gordo para abate',
      ),
      MarketModel(
        id: 'cafe_arabica',
        name: 'Café Arábica',
        symbol: 'CAFE',
        type: MarketType.coffee,
        currentPrice: 1245.30,
        previousPrice: 1220.15,
        changePercent: 2.06,
        volume: 8500,
        currency: 'BRL',
        unit: 'sc/60kg',
        exchange: 'BMF',
        lastUpdated: DateTime.now(),
        status: MarketStatus.open,
        description: 'Café arábica tipo 6',
      ),
      MarketModel(
        id: 'acucar_cristal',
        name: 'Açúcar Cristal',
        symbol: 'ACU',
        type: MarketType.sugar,
        currentPrice: 82.45,
        previousPrice: 84.20,
        changePercent: -2.08,
        volume: 22000,
        currency: 'BRL',
        unit: 'sc/50kg',
        exchange: 'BMF',
        lastUpdated: DateTime.now(),
        status: MarketStatus.open,
        description: 'Açúcar cristal especial',
      ),
    ];
  }

  @override
  Future<List<MarketModel>> getMarkets({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    var markets = _generateMockMarkets();
    if (filter != null) {
      if (filter.types?.isNotEmpty == true) {
        markets = markets.where((m) => filter.types!.contains(m.type)).toList();
      }
      if (filter.searchQuery?.isNotEmpty == true) {
        final query = filter.searchQuery!.toLowerCase();
        markets = markets.where((m) => 
          m.name.toLowerCase().contains(query) ||
          m.symbol.toLowerCase().contains(query)
        ).toList();
      }
    }
    final startIndex = offset.clamp(0, markets.length);
    final endIndex = (offset + limit).clamp(0, markets.length);
    
    return markets.sublist(startIndex, endIndex);
  }

  @override
  Future<MarketModel> getMarketById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    
    final markets = _generateMockMarkets();
    final market = markets.firstWhere((m) => m.id == id);
    return market;
  }

  @override
  Future<List<MarketModel>> searchMarkets({
    required String query,
    MarketFilter? filter,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    
    return getMarkets(
      filter: filter?.copyWith(searchQuery: query),
      limit: limit,
    );
  }

  @override
  Future<List<MarketModel>> getMarketsByType({
    required MarketType type,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    
    final markets = _generateMockMarkets();
    return markets.where((m) => m.type == type).take(limit).toList();
  }

  @override
  Future<MarketSummaryModel> getMarketSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    
    final markets = _generateMockMarkets();
    final gainers = markets.where((m) => m.isUp).toList();
    final losers = markets.where((m) => m.isDown).toList();
    
    return MarketSummaryModel(
      marketName: 'Mercado Agrícola Brasileiro',
      lastUpdated: DateTime.now(),
      topGainers: gainers.take(3).toList(),
      topLosers: losers.take(3).toList(),
      mostActive: markets.take(3).toList(),
      marketIndex: 1250.75,
      marketIndexChange: 1.85,
      totalMarkets: markets.length,
      marketsUp: gainers.length,
      marketsDown: losers.length,
      marketsUnchanged: markets.where((m) => m.isStable).length,
    );
  }

  @override
  Future<List<MarketModel>> getTopGainers({
    int limit = 10,
    MarketType? type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    
    var markets = _generateMockMarkets();
    markets = markets.where((m) => m.isUp).toList();
    
    if (type != null) {
      markets = markets.where((m) => m.type == type).toList();
    }
    
    markets.sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return markets.take(limit).toList();
  }

  @override
  Future<List<MarketModel>> getTopLosers({
    int limit = 10,
    MarketType? type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    
    var markets = _generateMockMarkets();
    markets = markets.where((m) => m.isDown).toList();
    
    if (type != null) {
      markets = markets.where((m) => m.type == type).toList();
    }
    
    markets.sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return markets.take(limit).toList();
  }

  @override
  Future<List<MarketModel>> getMostActive({
    int limit = 10,
    MarketType? type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    
    var markets = _generateMockMarkets();
    
    if (type != null) {
      markets = markets.where((m) => m.type == type).toList();
    }
    
    markets.sort((a, b) => b.volume.compareTo(a.volume));
    return markets.take(limit).toList();
  }

  @override
  Future<List<PriceHistoryModel>> getMarketHistory({
    required String marketId,
    required DateTime startDate,
    required DateTime endDate,
    String interval = '1d',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final history = <PriceHistoryModel>[];
    final days = endDate.difference(startDate).inDays;
    var currentPrice = 100.0;
    
    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      final variance = (i % 5 - 2) * 2.5; // Mock price variation
      currentPrice += variance;
      
      history.add(PriceHistoryModel(
        date: date,
        price: currentPrice,
        volume: 1000 + (i * 100),
        high: currentPrice + 2.5,
        low: currentPrice - 2.0,
        open: currentPrice - 1.0,
        close: currentPrice,
      ));
    }
    
    return history;
  }
}