import 'package:app_agrihurbi/features/markets/data/models/market_model.dart';
import 'package:core/core.dart';

/// Abstract Market Local DataSource
abstract class MarketLocalDataSource {
  /// Cache markets data
  Future<void> cacheMarkets(List<MarketModel> markets);

  /// Get cached markets
  Future<List<MarketModel>> getCachedMarkets();

  /// Cache market by ID
  Future<void> cacheMarket(MarketModel market);

  /// Get cached market by ID
  Future<MarketModel?> getCachedMarket(String id);

  /// Clear markets cache
  Future<void> clearMarketsCache();

  /// Cache market summary
  Future<void> cacheMarketSummary(MarketSummaryModel summary);

  /// Get cached market summary
  Future<MarketSummaryModel?> getCachedMarketSummary();

  /// Save favorite markets
  Future<void> saveFavoriteMarkets(List<String> marketIds);

  /// Get favorite market IDs
  Future<List<String>> getFavoriteMarketIds();

  /// Add market to favorites
  Future<void> addToFavorites(String marketId);

  /// Remove market from favorites
  Future<void> removeFromFavorites(String marketId);

  /// Check if market is favorite
  Future<bool> isMarketFavorite(String marketId);

  /// Save search history
  Future<void> saveSearchQuery(String query);

  /// Get search history
  Future<List<String>> getSearchHistory();

  /// Clear search history
  Future<void> clearSearchHistory();

  /// Cache last update timestamp
  Future<void> cacheLastUpdate(DateTime timestamp);

  /// Get last update timestamp
  Future<DateTime?> getLastUpdate();
}

/// Implementation of Market Local DataSource using Hive
@Injectable(as: MarketLocalDataSource)
class MarketLocalDataSourceImpl implements MarketLocalDataSource {
  static const String _marketsBoxName = 'markets';
  static const String _favoritesBoxName = 'market_favorites';
  static const String _searchHistoryBoxName = 'market_search_history';
  static const String _cacheInfoBoxName = 'market_cache_info';

  static const String _marketsKey = 'cached_markets';
  static const String _summaryKey = 'market_summary';
  static const String _favoritesKey = 'favorite_market_ids';
  static const String _searchHistoryKey = 'search_queries';
  static const String _lastUpdateKey = 'last_update';

  Box<dynamic>? _marketsBox;
  Box<dynamic>? _favoritesBox;
  Box<dynamic>? _searchHistoryBox;
  Box<dynamic>? _cacheInfoBox;

  /// Initialize boxes
  Future<void> _ensureBoxesAreOpen() async {
    _marketsBox ??= await Hive.openBox(_marketsBoxName);
    _favoritesBox ??= await Hive.openBox(_favoritesBoxName);
    _searchHistoryBox ??= await Hive.openBox(_searchHistoryBoxName);
    _cacheInfoBox ??= await Hive.openBox(_cacheInfoBoxName);
  }

  @override
  Future<void> cacheMarkets(List<MarketModel> markets) async {
    await _ensureBoxesAreOpen();
    final marketsJson = markets.map((m) => m.toJson()).toList();
    await _marketsBox!.put(_marketsKey, marketsJson);
  }

  @override
  Future<List<MarketModel>> getCachedMarkets() async {
    await _ensureBoxesAreOpen();
    final marketsJson = _marketsBox!.get(_marketsKey) as List<dynamic>?;
    
    if (marketsJson == null) return [];
    
    return marketsJson
        .cast<Map<String, dynamic>>()
        .map((json) => MarketModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> cacheMarket(MarketModel market) async {
    await _ensureBoxesAreOpen();
    await _marketsBox!.put('market_${market.id}', market.toJson());
  }

  @override
  Future<MarketModel?> getCachedMarket(String id) async {
    await _ensureBoxesAreOpen();
    final marketJson = _marketsBox!.get('market_$id') as Map<String, dynamic>?;
    
    if (marketJson == null) return null;
    
    return MarketModel.fromJson(Map<String, dynamic>.from(marketJson));
  }

  @override
  Future<void> clearMarketsCache() async {
    await _ensureBoxesAreOpen();
    await _marketsBox!.clear();
  }

  @override
  Future<void> cacheMarketSummary(MarketSummaryModel summary) async {
    await _ensureBoxesAreOpen();
    await _marketsBox!.put(_summaryKey, summary.toJson());
  }

  @override
  Future<MarketSummaryModel?> getCachedMarketSummary() async {
    await _ensureBoxesAreOpen();
    final summaryJson = _marketsBox!.get(_summaryKey) as Map<String, dynamic>?;
    
    if (summaryJson == null) return null;
    
    return MarketSummaryModel.fromJson(Map<String, dynamic>.from(summaryJson));
  }

  @override
  Future<void> saveFavoriteMarkets(List<String> marketIds) async {
    await _ensureBoxesAreOpen();
    await _favoritesBox!.put(_favoritesKey, marketIds);
  }

  @override
  Future<List<String>> getFavoriteMarketIds() async {
    await _ensureBoxesAreOpen();
    final favoriteIds = _favoritesBox!.get(_favoritesKey) as List<dynamic>?;
    return favoriteIds?.cast<String>() ?? [];
  }

  @override
  Future<void> addToFavorites(String marketId) async {
    await _ensureBoxesAreOpen();
    final favoriteIds = await getFavoriteMarketIds();
    if (!favoriteIds.contains(marketId)) {
      favoriteIds.add(marketId);
      await saveFavoriteMarkets(favoriteIds);
    }
  }

  @override
  Future<void> removeFromFavorites(String marketId) async {
    await _ensureBoxesAreOpen();
    final favoriteIds = await getFavoriteMarketIds();
    favoriteIds.remove(marketId);
    await saveFavoriteMarkets(favoriteIds);
  }

  @override
  Future<bool> isMarketFavorite(String marketId) async {
    await _ensureBoxesAreOpen();
    final favoriteIds = await getFavoriteMarketIds();
    return favoriteIds.contains(marketId);
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    await _ensureBoxesAreOpen();
    final searchHistory = await getSearchHistory();
    searchHistory.remove(query);
    searchHistory.insert(0, query);
    if (searchHistory.length > 20) {
      searchHistory.removeRange(20, searchHistory.length);
    }
    
    await _searchHistoryBox!.put(_searchHistoryKey, searchHistory);
  }

  @override
  Future<List<String>> getSearchHistory() async {
    await _ensureBoxesAreOpen();
    final history = _searchHistoryBox!.get(_searchHistoryKey) as List<dynamic>?;
    return history?.cast<String>() ?? [];
  }

  @override
  Future<void> clearSearchHistory() async {
    await _ensureBoxesAreOpen();
    await _searchHistoryBox!.delete(_searchHistoryKey);
  }

  @override
  Future<void> cacheLastUpdate(DateTime timestamp) async {
    await _ensureBoxesAreOpen();
    await _cacheInfoBox!.put(_lastUpdateKey, timestamp.toIso8601String());
  }

  @override
  Future<DateTime?> getLastUpdate() async {
    await _ensureBoxesAreOpen();
    final timestampStr = _cacheInfoBox!.get(_lastUpdateKey) as String?;
    return timestampStr != null ? DateTime.tryParse(timestampStr) : null;
  }
}
