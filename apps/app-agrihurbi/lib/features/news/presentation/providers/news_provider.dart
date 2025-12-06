import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/commodity_price_entity.dart';
import '../../domain/entities/news_article_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/usecases/get_commodity_prices.dart';
import '../../domain/usecases/get_news.dart';
import 'news_di_providers.dart';

part 'news_provider.g.dart';

/// State class for News
class NewsState {
  final List<NewsArticleEntity> articles;
  final List<NewsArticleEntity> premiumArticles;
  final List<NewsArticleEntity> favoriteArticles;
  final List<NewsArticleEntity> searchResults;
  final List<CommodityPriceEntity> commodityPrices;
  final MarketSummaryEntity? marketSummary;
  final bool isLoadingNews;
  final bool isLoadingPremium;
  final bool isLoadingCommodities;
  final bool isRefreshing;
  final bool isSearching;
  final String? errorMessage;
  final NewsFilter? currentFilter;
  final String currentSearchQuery;
  final DateTime? lastRSSUpdate;
  final List<String> rssSources;

  const NewsState({
    this.articles = const [],
    this.premiumArticles = const [],
    this.favoriteArticles = const [],
    this.searchResults = const [],
    this.commodityPrices = const [],
    this.marketSummary,
    this.isLoadingNews = false,
    this.isLoadingPremium = false,
    this.isLoadingCommodities = false,
    this.isRefreshing = false,
    this.isSearching = false,
    this.errorMessage,
    this.currentFilter,
    this.currentSearchQuery = '',
    this.lastRSSUpdate,
    this.rssSources = const [],
  });

  NewsState copyWith({
    List<NewsArticleEntity>? articles,
    List<NewsArticleEntity>? premiumArticles,
    List<NewsArticleEntity>? favoriteArticles,
    List<NewsArticleEntity>? searchResults,
    List<CommodityPriceEntity>? commodityPrices,
    MarketSummaryEntity? marketSummary,
    bool? isLoadingNews,
    bool? isLoadingPremium,
    bool? isLoadingCommodities,
    bool? isRefreshing,
    bool? isSearching,
    String? errorMessage,
    NewsFilter? currentFilter,
    String? currentSearchQuery,
    DateTime? lastRSSUpdate,
    List<String>? rssSources,
    bool clearMarketSummary = false,
    bool clearError = false,
    bool clearCurrentFilter = false,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      premiumArticles: premiumArticles ?? this.premiumArticles,
      favoriteArticles: favoriteArticles ?? this.favoriteArticles,
      searchResults: searchResults ?? this.searchResults,
      commodityPrices: commodityPrices ?? this.commodityPrices,
      marketSummary: clearMarketSummary ? null : (marketSummary ?? this.marketSummary),
      isLoadingNews: isLoadingNews ?? this.isLoadingNews,
      isLoadingPremium: isLoadingPremium ?? this.isLoadingPremium,
      isLoadingCommodities: isLoadingCommodities ?? this.isLoadingCommodities,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentFilter: clearCurrentFilter ? null : (currentFilter ?? this.currentFilter),
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      lastRSSUpdate: lastRSSUpdate ?? this.lastRSSUpdate,
      rssSources: rssSources ?? this.rssSources,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasData => articles.isNotEmpty;
}

/// News Notifier using Riverpod code generation
@riverpod
class NewsNotifier extends _$NewsNotifier {
  GetNews get _getNews => ref.read(getNewsUseCaseProvider);
  GetArticleById get _getArticleById => ref.read(getArticleByIdUseCaseProvider);
  SearchArticles get _searchArticles => ref.read(searchArticlesUseCaseProvider);
  GetPremiumArticles get _getPremiumArticles => ref.read(getPremiumArticlesUseCaseProvider);
  ManageFavorites get _manageFavorites => ref.read(manageFavoritesUseCaseProvider);
  RefreshRSSFeeds get _refreshRSSFeeds => ref.read(refreshRSSFeedsUseCaseProvider);
  GetCommodityPrices get _getCommodityPrices => ref.read(getCommodityPricesUseCaseProvider);
  NewsRepository get _repository => ref.read(newsRepositoryProvider);

  @override
  NewsState build() {
    return const NewsState();
  }

  // Convenience getters for backward compatibility
  List<NewsArticleEntity> get articles => state.articles;
  List<NewsArticleEntity> get premiumArticles => state.premiumArticles;
  List<NewsArticleEntity> get favoriteArticles => state.favoriteArticles;
  List<NewsArticleEntity> get searchResults => state.searchResults;
  List<CommodityPriceEntity> get commodityPrices => state.commodityPrices;
  MarketSummaryEntity? get marketSummary => state.marketSummary;
  bool get isLoadingNews => state.isLoadingNews;
  bool get isLoadingPremium => state.isLoadingPremium;
  bool get isLoadingCommodities => state.isLoadingCommodities;
  bool get isRefreshing => state.isRefreshing;
  bool get isSearching => state.isSearching;
  String? get errorMessage => state.errorMessage;
  NewsFilter? get currentFilter => state.currentFilter;
  String get currentSearchQuery => state.currentSearchQuery;
  DateTime? get lastRSSUpdate => state.lastRSSUpdate;
  List<String> get rssSources => state.rssSources;
  bool get hasError => state.hasError;
  bool get hasData => state.hasData;

  /// Load news articles with optional filter
  Future<void> loadNews({
    NewsFilter? filter,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (state.isLoadingNews && !refresh) return;

    state = state.copyWith(isLoadingNews: true, clearError: true);

    try {
      final result = await _getNews(filter: filter, limit: limit);

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar notícias: ${failure.message}',
          isLoadingNews: false,
        ),
        (articles) {
          state = state.copyWith(
            articles: articles,
            currentFilter: filter,
            isLoadingNews: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingNews: false,
      );
    }
  }

  /// Load premium articles
  Future<void> loadPremiumNews({int limit = 10, bool refresh = false}) async {
    if (state.isLoadingPremium && !refresh) return;

    state = state.copyWith(isLoadingPremium: true, clearError: true);

    try {
      final result = await _getPremiumArticles(limit: limit);

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar notícias premium: ${failure.message}',
          isLoadingPremium: false,
        ),
        (articles) {
          state = state.copyWith(
            premiumArticles: articles,
            isLoadingPremium: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingPremium: false,
      );
    }
  }

  /// Search news articles
  Future<void> searchNews({
    required String query,
    NewsFilter? filter,
    int limit = 20,
  }) async {
    if (query.isEmpty) {
      state = state.copyWith(
        searchResults: [],
        currentSearchQuery: '',
      );
      return;
    }

    state = state.copyWith(isSearching: true, clearError: true);

    try {
      final result = await _searchArticles(
        query: query,
        filter: filter,
        limit: limit,
      );

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro na busca: ${failure.message}',
          isSearching: false,
        ),
        (articles) {
          state = state.copyWith(
            searchResults: articles,
            currentSearchQuery: query,
            isSearching: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isSearching: false,
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

  /// Get article by ID
  Future<NewsArticleEntity?> getArticleById(String id) async {
    try {
      final result = await _getArticleById(id);
      return result.fold((failure) {
        state = state.copyWith(
          errorMessage: 'Erro ao carregar artigo: ${failure.message}',
        );
        return null;
      }, (article) => article);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
      return null;
    }
  }

  /// Load favorite articles
  Future<void> loadFavorites() async {
    try {
      final result = await _manageFavorites.getFavorites();

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar favoritos: ${failure.message}',
        ),
        (articles) {
          state = state.copyWith(favoriteArticles: articles);
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
    }
  }

  /// Add article to favorites
  Future<bool> addToFavorites(String articleId) async {
    try {
      final result = await _manageFavorites.addToFavorites(articleId);

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

  /// Remove article from favorites
  Future<bool> removeFromFavorites(String articleId) async {
    try {
      final result = await _manageFavorites.removeFromFavorites(articleId);

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

  /// Check if article is favorite
  Future<bool> isArticleFavorite(String articleId) async {
    try {
      final result = await _manageFavorites.isFavorite(articleId);

      return result.fold((failure) => false, (isFavorite) => isFavorite);
    } catch (e) {
      return false;
    }
  }

  /// Refresh RSS feeds
  Future<void> refreshRSSFeeds() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final result = await _refreshRSSFeeds();

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao atualizar feeds: ${failure.message}',
          isRefreshing: false,
        ),
        (_) async {
          await _updateLastRSSTime();
          await loadNews(refresh: true);
          state = state.copyWith(isRefreshing: false);
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isRefreshing: false,
      );
    }
  }

  /// Update last RSS update time
  Future<void> _updateLastRSSTime() async {
    try {
      final result = await _repository.getLastRSSUpdate();
      result.fold((failure) => null, (lastUpdate) {
        state = state.copyWith(lastRSSUpdate: lastUpdate);
      });
    } catch (e) {
      // Silent error
    }
  }

  /// Get RSS sources
  Future<void> loadRSSSources() async {
    try {
      final result = await _repository.getRSSSources();
      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar feeds RSS: ${failure.message}',
        ),
        (sources) {
          state = state.copyWith(rssSources: sources);
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
    }
  }

  /// Add RSS source
  Future<bool> addRSSSource(String feedUrl) async {
    try {
      final result = await _repository.addRSSSource(feedUrl);

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao adicionar feed RSS: ${failure.message}',
          );
          return false;
        },
        (_) {
          loadRSSSources();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
      return false;
    }
  }

  /// Remove RSS source
  Future<bool> removeRSSSource(String feedUrl) async {
    try {
      final result = await _repository.removeRSSSource(feedUrl);

      return result.fold(
        (failure) {
          state = state.copyWith(
            errorMessage: 'Erro ao remover feed RSS: ${failure.message}',
          );
          return false;
        },
        (_) {
          loadRSSSources();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
      return false;
    }
  }

  /// Load commodity prices
  Future<void> loadCommodityPrices({
    List<CommodityType>? types,
    bool refresh = false,
  }) async {
    if (state.isLoadingCommodities && !refresh) return;

    state = state.copyWith(isLoadingCommodities: true, clearError: true);

    try {
      final result = await _getCommodityPrices(types: types);

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar preços: ${failure.message}',
          isLoadingCommodities: false,
        ),
        (prices) {
          state = state.copyWith(
            commodityPrices: prices,
            isLoadingCommodities: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro inesperado: $e',
        isLoadingCommodities: false,
      );
    }
  }

  /// Load market summary
  Future<void> loadMarketSummary() async {
    try {
      final result = await _repository.getMarketSummary();

      result.fold(
        (failure) => state = state.copyWith(
          errorMessage: 'Erro ao carregar resumo do mercado: ${failure.message}',
        ),
        (summary) {
          state = state.copyWith(marketSummary: summary);
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro inesperado: $e');
    }
  }

  /// Apply news filter
  void applyFilter(NewsFilter filter) {
    state = state.copyWith(currentFilter: filter);
    loadNews(filter: filter);
  }

  /// Clear current filter
  void clearFilter() {
    state = state.copyWith(clearCurrentFilter: true);
    loadNews();
  }

  /// Filter by category
  void filterByCategory(NewsCategory category) {
    final filter = NewsFilter(categories: [category]);
    applyFilter(filter);
  }

  /// Show only premium articles
  void showOnlyPremium(bool showOnly) {
    final filter = (state.currentFilter ?? const NewsFilter()).copyWith(
      showOnlyPremium: showOnly,
    );
    applyFilter(filter);
  }

  /// Initialize provider
  Future<void> initialize() async {
    await Future.wait([
      loadNews(),
      loadCommodityPrices(),
      loadFavorites(),
      loadRSSSources(),
      _updateLastRSSTime(),
    ]);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      refreshRSSFeeds(),
      loadCommodityPrices(refresh: true),
      loadMarketSummary(),
    ]);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
