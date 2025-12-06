import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/market_entity.dart';
import '../../domain/entities/market_filter_entity.dart';
import '../../domain/repositories/market_repository.dart';
import '../../domain/usecases/get_market_summary.dart';
import '../../domain/usecases/get_markets.dart';
import '../../domain/usecases/manage_market_favorites.dart';
import 'markets_di_providers.dart';

part 'market_provider.g.dart';

/// State class for Market
class MarketState {
  final List<MarketEntity> markets;
  final List<MarketEntity> favoriteMarkets;
  final List<MarketEntity> searchResults;
  final List<MarketEntity> topGainers;
  final List<MarketEntity> topLosers;
  final List<MarketEntity> mostActive;
  final MarketSummary? marketSummary;
  final bool isLoadingMarkets;
  final bool isLoadingSummary;
  final bool isLoadingFavorites;
  final bool isLoadingSearch;
  final bool isRefreshing;
  final String? errorMessage;
  final MarketFilter currentFilter;
  final String currentSearchQuery;
  final DateTime? lastUpdate;
  final List<String> searchHistory;

  const MarketState({
    this.markets = const [],
    this.favoriteMarkets = const [],
    this.searchResults = const [],
    this.topGainers = const [],
    this.topLosers = const [],
    this.mostActive = const [],
    this.marketSummary,
    this.isLoadingMarkets = false,
    this.isLoadingSummary = false,
    this.isLoadingFavorites = false,
    this.isLoadingSearch = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.currentFilter = const MarketFilter(),
    this.currentSearchQuery = '',
    this.lastUpdate,
    this.searchHistory = const [],
  });

  MarketState copyWith({
    List<MarketEntity>? markets,
    List<MarketEntity>? favoriteMarkets,
    List<MarketEntity>? searchResults,
    List<MarketEntity>? topGainers,
    List<MarketEntity>? topLosers,
    List<MarketEntity>? mostActive,
    MarketSummary? marketSummary,
    bool? isLoadingMarkets,
    bool? isLoadingSummary,
    bool? isLoadingFavorites,
    bool? isLoadingSearch,
    bool? isRefreshing,
    String? errorMessage,
    MarketFilter? currentFilter,
    String? currentSearchQuery,
    DateTime? lastUpdate,
    List<String>? searchHistory,
    bool clearMarketSummary = false,
    bool clearError = false,
  }) {
    return MarketState(
      markets: markets ?? this.markets,
      favoriteMarkets: favoriteMarkets ?? this.favoriteMarkets,
      searchResults: searchResults ?? this.searchResults,
      topGainers: topGainers ?? this.topGainers,
      topLosers: topLosers ?? this.topLosers,
      mostActive: mostActive ?? this.mostActive,
      marketSummary: clearMarketSummary ? null : (marketSummary ?? this.marketSummary),
      isLoadingMarkets: isLoadingMarkets ?? this.isLoadingMarkets,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      isLoadingFavorites: isLoadingFavorites ?? this.isLoadingFavorites,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentFilter: currentFilter ?? this.currentFilter,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasData => markets.isNotEmpty;
  bool get hasSearchResults => searchResults.isNotEmpty;
}

/// Market Notifier using Riverpod code generation
@riverpod
class MarketNotifier extends _$MarketNotifier {
  GetMarkets get _getMarkets => ref.read(getMarketsUseCaseProvider);
  GetMarketSummary get _getMarketSummary => ref.read(getMarketSummaryUseCaseProvider);
  GetTopGainers get _getTopGainers => ref.read(getTopGainersUseCaseProvider);
  GetTopLosers get _getTopLosers => ref.read(getTopLosersUseCaseProvider);
  GetMostActive get _getMostActive => ref.read(getMostActiveUseCaseProvider);
  ManageMarketFavorites get _manageFavorites => ref.read(manageMarketFavoritesUseCaseProvider);
  MarketRepository get _repository => ref.read(marketRepositoryProvider);

  @override
  MarketState build() {
    return const MarketState();
  }

  // Convenience getters for backward compatibility
  List<MarketEntity> get markets => state.markets;
  List<MarketEntity> get favoriteMarkets => state.favoriteMarkets;
  List<MarketEntity> get searchResults => state.searchResults;
  List<MarketEntity> get topGainers => state.topGainers;
  List<MarketEntity> get topLosers => state.topLosers;
  List<MarketEntity> get mostActive => state.mostActive;
  MarketSummary? get marketSummary => state.marketSummary;
  bool get isLoadingMarkets => state.isLoadingMarkets;
  bool get isLoadingSummary => state.isLoadingSummary;
  bool get isLoadingFavorites => state.isLoadingFavorites;
  bool get isLoadingSearch => state.isLoadingSearch;
  bool get isRefreshing => state.isRefreshing;
  String? get errorMessage => state.errorMessage;
  MarketFilter get currentFilter => state.currentFilter;
  String get currentSearchQuery => state.currentSearchQuery;
  DateTime? get lastUpdate => state.lastUpdate;
  List<String> get searchHistory => state.searchHistory;
  bool get hasError => state.hasError;
  bool get hasData => state.hasData;
  bool get hasSearchResults => state.hasSearchResults;

  /// Load markets with optional filter
  Future<void> loadMarkets({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
    bool refresh = false,
  }) async {
    if (state.isLoadingMarkets && !refresh) return;

    state = state.copyWith(isLoadingMarkets: true, clearError: true);

    try {
      final result = await _getMarkets(
        filter: filter,
        limit: limit,
        offset: offset,
      );

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar mercados: ${failure.message}',
          isLoadingMarkets: false,
        ),
        (markets) {
          state = state.copyWith(
            markets: markets,
            currentFilter: filter ?? const MarketFilter(),
            lastUpdate: DateTime.now(),
            isLoadingMarkets: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingMarkets: false,
      );
    }
  }

  /// Load market summary with top performers
  Future<void> loadMarketSummary({bool refresh = false}) async {
    if (state.isLoadingSummary && !refresh) return;

    state = state.copyWith(isLoadingSummary: true, clearError: true);

    try {
      final result = await _getMarketSummary();

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar resumo: ${failure.message}',
          isLoadingSummary: false,
        ),
        (summary) {
          state = state.copyWith(
            marketSummary: summary,
            isLoadingSummary: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingSummary: false,
      );
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

      List<MarketEntity> gainers = state.topGainers;
      List<MarketEntity> losers = state.topLosers;
      List<MarketEntity> active = state.mostActive;

      results[0].fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar maiores altas: ${failure.message}',
        ),
        (data) => gainers = data,
      );

      results[1].fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar maiores quedas: ${failure.message}',
        ),
        (data) => losers = data,
      );

      results[2].fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar mais negociados: ${failure.message}',
        ),
        (data) => active = data,
      );

      state = state.copyWith(
        topGainers: gainers,
        topLosers: losers,
        mostActive: active,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
    }
  }

  /// Search markets
  Future<void> searchMarkets({
    required String query,
    MarketFilter? filter,
    int limit = 20,
  }) async {
    if (query.isEmpty) {
      state = state.copyWith(
        searchResults: [],
        currentSearchQuery: '',
      );
      return;
    }

    state = state.copyWith(isLoadingSearch: true, clearError: true);

    try {
      final result = await _repository.searchMarkets(
        query: query,
        filter: filter,
        limit: limit,
      );

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro na busca: ${failure.message}',
          isLoadingSearch: false,
        ),
        (results) {
          state = state.copyWith(
            searchResults: results,
            currentSearchQuery: query,
            isLoadingSearch: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingSearch: false,
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    state = state.copyWith(
      searchResults: [],
      currentSearchQuery: '',
    );
  }

  /// Get market by ID
  Future<MarketEntity?> getMarketById(String id) async {
    try {
      final result = await _repository.getMarketById(id);
      return result.fold((failure) {
        state = state.copyWith(
          errorMessage: 'Erro ao carregar mercado: ${failure.message}',
        );
        return null;
      }, (market) => market);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
      return null;
    }
  }

  /// Get markets by type
  Future<void> loadMarketsByType({
    required MarketType type,
    int limit = 20,
  }) async {
    state = state.copyWith(isLoadingMarkets: true, clearError: true);

    try {
      final result = await _repository.getMarketsByType(
        type: type,
        limit: limit,
      );

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar mercados: ${failure.message}',
          isLoadingMarkets: false,
        ),
        (markets) {
          state = state.copyWith(
            markets: markets,
            currentFilter: MarketFilter(types: [type]),
            isLoadingMarkets: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingMarkets: false,
      );
    }
  }

  /// Load favorite markets
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoadingFavorites: true, clearError: true);

    try {
      final result = await _manageFavorites.getFavorites();

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar favoritos: ${failure.message}',
          isLoadingFavorites: false,
        ),
        (favorites) {
          state = state.copyWith(
            favoriteMarkets: favorites,
            isLoadingFavorites: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingFavorites: false,
      );
    }
  }

  /// Add market to favorites
  Future<bool> addToFavorites(String marketId) async {
    try {
      final result = await _manageFavorites.addToFavorites(marketId);

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao adicionar favorito: ${failure.message}',
          );
          return false;
        },
        (_) {
          loadFavorites();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
      return false;
    }
  }

  /// Remove market from favorites
  Future<bool> removeFromFavorites(String marketId) async {
    try {
      final result = await _manageFavorites.removeFromFavorites(marketId);

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao remover favorito: ${failure.message}',
          );
          return false;
        },
        (_) {
          loadFavorites();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String marketId) async {
    try {
      final result = await _manageFavorites.toggleFavorite(marketId);

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao alterar favorito: ${failure.message}',
          );
          return false;
        },
        (isFavorite) {
          loadFavorites();
          return isFavorite;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
      return false;
    }
  }

  /// Check if market is favorite
  Future<bool> isMarketFavorite(String marketId) async {
    try {
      final result = await _manageFavorites.isFavorite(marketId);

      return result.fold((failure) => false, (isFavorite) => isFavorite);
    } catch (e) {
      return false;
    }
  }

  /// Apply filter
  void applyFilter(MarketFilter filter) {
    state = state.copyWith(currentFilter: filter);
    loadMarkets(filter: filter);
  }

  /// Clear current filter
  void clearFilter() {
    state = state.copyWith(currentFilter: const MarketFilter());
    loadMarkets();
  }

  /// Filter by type
  void filterByType(MarketType type) {
    final filter = state.currentFilter.copyWith(types: [type]);
    applyFilter(filter);
  }

  /// Filter by exchange
  void filterByExchange(String exchange) {
    final filter = state.currentFilter.copyWith(exchanges: [exchange]);
    applyFilter(filter);
  }

  /// Show only favorites
  void showOnlyFavorites(bool showOnly) {
    final filter = state.currentFilter.copyWith(onlyFavorites: showOnly);
    applyFilter(filter);
  }

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
    state = state.copyWith(isRefreshing: true);

    try {
      await _repository.refreshMarketData();
      await initialize();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar dados: $e');
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Load search history
  Future<void> _loadSearchHistory() async {
    try {
      state = state.copyWith(searchHistory: []);
    } catch (e) {
      // Silent error
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
