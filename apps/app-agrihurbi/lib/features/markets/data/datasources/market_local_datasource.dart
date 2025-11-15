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

/// Implementation of Market Local DataSource
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

  @override
  Future<void> cacheMarkets(List<MarketModel> markets) async {
    throw UnimplementedError('cacheMarkets has not been implemented');
  }

  @override
  Future<List<MarketModel>> getCachedMarkets() async {
    throw UnimplementedError('getCachedMarkets has not been implemented');
  }

  @override
  Future<void> cacheMarket(MarketModel market) async {
    throw UnimplementedError('cacheMarket has not been implemented');
  }

  @override
  Future<MarketModel?> getCachedMarket(String id) async {
    throw UnimplementedError('getCachedMarket has not been implemented');
  }

  @override
  Future<void> clearMarketsCache() async {
    throw UnimplementedError('clearMarketsCache has not been implemented');
  }

  @override
  Future<void> cacheMarketSummary(MarketSummaryModel summary) async {
    throw UnimplementedError('cacheMarketSummary has not been implemented');
  }

  @override
  Future<MarketSummaryModel?> getCachedMarketSummary() async {
    throw UnimplementedError('getCachedMarketSummary has not been implemented');
  }

  @override
  Future<void> saveFavoriteMarkets(List<String> marketIds) async {
    throw UnimplementedError('saveFavoriteMarkets has not been implemented');
  }

  @override
  Future<List<String>> getFavoriteMarketIds() async {
    throw UnimplementedError('getFavoriteMarketIds has not been implemented');
  }

  @override
  Future<void> addToFavorites(String marketId) async {
    throw UnimplementedError('addToFavorites has not been implemented');
  }

  @override
  Future<void> removeFromFavorites(String marketId) async {
    throw UnimplementedError('removeFromFavorites has not been implemented');
  }

  @override
  Future<bool> isMarketFavorite(String marketId) async {
    throw UnimplementedError('isMarketFavorite has not been implemented');
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    throw UnimplementedError('saveSearchQuery has not been implemented');
  }

  @override
  Future<List<String>> getSearchHistory() async {
    throw UnimplementedError('getSearchHistory has not been implemented');
  }

  @override
  Future<void> clearSearchHistory() async {
    throw UnimplementedError('clearSearchHistory has not been implemented');
  }

  @override
  Future<void> cacheLastUpdate(DateTime timestamp) async {
    throw UnimplementedError('cacheLastUpdate has not been implemented');
  }

  @override
  Future<DateTime?> getLastUpdate() async {
    throw UnimplementedError('getLastUpdate has not been implemented');
  }
}
