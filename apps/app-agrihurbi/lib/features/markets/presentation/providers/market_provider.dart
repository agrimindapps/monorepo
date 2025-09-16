import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_filter_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/repositories/market_repository.dart';
import 'package:app_agrihurbi/features/markets/domain/usecases/get_market_summary.dart';
import 'package:app_agrihurbi/features/markets/domain/usecases/get_markets.dart';
import 'package:app_agrihurbi/features/markets/domain/usecases/manage_market_favorites.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Market Provider for State Management
/// 
/// Manages market data, filtering, favorites, and search state
/// using Provider pattern for reactive UI updates
@injectable
class MarketProvider with ChangeNotifier {
  final GetMarkets _getMarkets;
  final GetMarketSummary _getMarketSummary;
  final GetTopGainers _getTopGainers;
  final GetTopLosers _getTopLosers;
  final GetMostActive _getMostActive;
  final ManageMarketFavorites _manageFavorites;
  final MarketRepository _repository;

  MarketProvider(
    this._getMarkets,
    this._getMarketSummary,
    this._getTopGainers,
    this._getTopLosers,
    this._getMostActive,
    this._manageFavorites,
    this._repository,
  );

  // === STATE VARIABLES ===

  List<MarketEntity> _markets = [];
  List<MarketEntity> _favoriteMarkets = [];
  List<MarketEntity> _searchResults = [];
  List<MarketEntity> _topGainers = [];
  List<MarketEntity> _topLosers = [];
  List<MarketEntity> _mostActive = [];
  MarketSummary? _marketSummary;

  bool _isLoadingMarkets = false;
  bool _isLoadingSummary = false;
  bool _isLoadingFavorites = false;
  bool _isLoadingSearch = false;
  bool _isRefreshing = false;

  String? _errorMessage;
  MarketFilter _currentFilter = const MarketFilter();
  String _currentSearchQuery = '';
  
  DateTime? _lastUpdate;
  List<String> _searchHistory = [];

  // === GETTERS ===

  List<MarketEntity> get markets => _markets;
  List<MarketEntity> get favoriteMarkets => _favoriteMarkets;
  List<MarketEntity> get searchResults => _searchResults;
  List<MarketEntity> get topGainers => _topGainers;
  List<MarketEntity> get topLosers => _topLosers;
  List<MarketEntity> get mostActive => _mostActive;
  MarketSummary? get marketSummary => _marketSummary;

  bool get isLoadingMarkets => _isLoadingMarkets;
  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isLoadingSearch => _isLoadingSearch;
  bool get isRefreshing => _isRefreshing;

  String? get errorMessage => _errorMessage;
  MarketFilter get currentFilter => _currentFilter;
  String get currentSearchQuery => _currentSearchQuery;
  
  DateTime? get lastUpdate => _lastUpdate;
  List<String> get searchHistory => _searchHistory;

  bool get hasError => _errorMessage != null;
  bool get hasData => _markets.isNotEmpty;
  bool get hasSearchResults => _searchResults.isNotEmpty;

  // === MARKET OPERATIONS ===

  /// Load markets with optional filter
  Future<void> loadMarkets({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
    bool refresh = false,
  }) async {
    if (_isLoadingMarkets && !refresh) return;

    _setLoadingMarkets(true);
    _clearError();

    try {
      final result = await _getMarkets(
        filter: filter,
        limit: limit,
        offset: offset,
      );
      
      result.fold(
        (failure) => _setError('Erro ao carregar mercados: ${failure.message}'),
        (markets) {
          _markets = markets;
          _currentFilter = filter ?? const MarketFilter();
          _lastUpdate = DateTime.now();
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingMarkets(false);
    }
  }

  /// Load market summary with top performers
  Future<void> loadMarketSummary({bool refresh = false}) async {
    if (_isLoadingSummary && !refresh) return;

    _setLoadingSummary(true);
    _clearError();

    try {
      final result = await _getMarketSummary();
      
      result.fold(
        (failure) => _setError('Erro ao carregar resumo: ${failure.message}'),
        (summary) {
          _marketSummary = summary;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingSummary(false);
    }
  }

  /// Load top performers data
  Future<void> loadTopPerformers({
    int limit = 5,
    MarketType? type,
    bool refresh = false,
  }) async {
    try {
      final results = await Future.wait([
        _getTopGainers(limit: limit, type: type),
        _getTopLosers(limit: limit, type: type),
        _getMostActive(limit: limit, type: type),
      ]);

      results[0].fold(
        (failure) => _setError('Erro ao carregar maiores altas: ${failure.message}'),
        (gainers) => _topGainers = gainers,
      );

      results[1].fold(
        (failure) => _setError('Erro ao carregar maiores quedas: ${failure.message}'),
        (losers) => _topLosers = losers,
      );

      results[2].fold(
        (failure) => _setError('Erro ao carregar mais negociados: ${failure.message}'),
        (active) => _mostActive = active,
      );

      notifyListeners();
    } catch (e) {
      _setError('Erro inesperado: $e');
    }
  }

  /// Search markets
  Future<void> searchMarkets({
    required String query,
    MarketFilter? filter,
    int limit = 20,
  }) async {
    if (query.isEmpty) {
      _searchResults = [];
      _currentSearchQuery = '';
      notifyListeners();
      return;
    }

    _setSearching(true);
    _clearError();

    try {
      final result = await _repository.searchMarkets(
        query: query,
        filter: filter,
        limit: limit,
      );
      
      result.fold(
        (failure) => _setError('Erro na busca: ${failure.message}'),
        (results) {
          _searchResults = results;
          _currentSearchQuery = query;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setSearching(false);
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _currentSearchQuery = '';
    notifyListeners();
  }

  /// Get market by ID
  Future<MarketEntity?> getMarketById(String id) async {
    try {
      final result = await _repository.getMarketById(id);
      return result.fold(
        (failure) {
          _setError('Erro ao carregar mercado: ${failure.message}');
          return null;
        },
        (market) => market,
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return null;
    }
  }

  /// Get markets by type
  Future<void> loadMarketsByType({
    required MarketType type,
    int limit = 20,
  }) async {
    _setLoadingMarkets(true);
    _clearError();

    try {
      final result = await _repository.getMarketsByType(
        type: type,
        limit: limit,
      );
      
      result.fold(
        (failure) => _setError('Erro ao carregar mercados: ${failure.message}'),
        (markets) {
          _markets = markets;
          _currentFilter = MarketFilter(types: [type]);
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingMarkets(false);
    }
  }

  // === FAVORITES MANAGEMENT ===

  /// Load favorite markets
  Future<void> loadFavorites() async {
    _setLoadingFavorites(true);
    _clearError();

    try {
      final result = await _manageFavorites.getFavorites();
      
      result.fold(
        (failure) => _setError('Erro ao carregar favoritos: ${failure.message}'),
        (favorites) {
          _favoriteMarkets = favorites;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingFavorites(false);
    }
  }

  /// Add market to favorites
  Future<bool> addToFavorites(String marketId) async {
    try {
      final result = await _manageFavorites.addToFavorites(marketId);
      
      return result.fold(
        (failure) {
          _setError('Erro ao adicionar favorito: ${failure.message}');
          return false;
        },
        (_) {
          // Refresh favorites list
          loadFavorites();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  /// Remove market from favorites
  Future<bool> removeFromFavorites(String marketId) async {
    try {
      final result = await _manageFavorites.removeFromFavorites(marketId);
      
      return result.fold(
        (failure) {
          _setError('Erro ao remover favorito: ${failure.message}');
          return false;
        },
        (_) {
          // Refresh favorites list
          loadFavorites();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String marketId) async {
    try {
      final result = await _manageFavorites.toggleFavorite(marketId);
      
      return result.fold(
        (failure) {
          _setError('Erro ao alterar favorito: ${failure.message}');
          return false;
        },
        (isFavorite) {
          // Refresh favorites list
          loadFavorites();
          return isFavorite;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  /// Check if market is favorite
  Future<bool> isMarketFavorite(String marketId) async {
    try {
      final result = await _manageFavorites.isFavorite(marketId);
      
      return result.fold(
        (failure) => false,
        (isFavorite) => isFavorite,
      );
    } catch (e) {
      return false;
    }
  }

  // === FILTER MANAGEMENT ===

  /// Apply filter
  void applyFilter(MarketFilter filter) {
    _currentFilter = filter;
    loadMarkets(filter: filter);
  }

  /// Clear current filter
  void clearFilter() {
    _currentFilter = const MarketFilter();
    loadMarkets();
  }

  /// Filter by type
  void filterByType(MarketType type) {
    final filter = _currentFilter.copyWith(types: [type]);
    applyFilter(filter);
  }

  /// Filter by exchange
  void filterByExchange(String exchange) {
    final filter = _currentFilter.copyWith(exchanges: [exchange]);
    applyFilter(filter);
  }

  /// Show only favorites
  void showOnlyFavorites(bool showOnly) {
    final filter = _currentFilter.copyWith(onlyFavorites: showOnly);
    applyFilter(filter);
  }

  // === UTILITY METHODS ===

  /// Initialize provider
  Future<void> initialize() async {
    await Future.wait([
      loadMarkets(),
      loadMarketSummary(),
      loadTopPerformers(),
      loadFavorites(),
      _loadSearchHistory(),
    ]);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    _setRefreshing(true);
    
    try {
      await _repository.refreshMarketData();
      await initialize();
    } catch (e) {
      _setError('Erro ao atualizar dados: $e');
    } finally {
      _setRefreshing(false);
    }
  }

  /// Load search history
  Future<void> _loadSearchHistory() async {
    try {
      // TODO: Implement search history loading from local datasource
      _searchHistory = [];
    } catch (e) {
      // Silent fail for search history
    }
  }

  // === PRIVATE METHODS ===

  void _setLoadingMarkets(bool loading) {
    _isLoadingMarkets = loading;
    notifyListeners();
  }

  void _setLoadingSummary(bool loading) {
    _isLoadingSummary = loading;
    notifyListeners();
  }

  void _setLoadingFavorites(bool loading) {
    _isLoadingFavorites = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isLoadingSearch = searching;
    notifyListeners();
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}