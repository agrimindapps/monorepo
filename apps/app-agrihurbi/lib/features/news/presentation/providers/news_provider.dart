import 'package:app_agrihurbi/core/di/injection.dart';
import 'package:app_agrihurbi/features/news/domain/entities/commodity_price_entity.dart';
import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';
import 'package:app_agrihurbi/features/news/domain/repositories/news_repository.dart';
import 'package:app_agrihurbi/features/news/domain/usecases/get_commodity_prices.dart';
import 'package:app_agrihurbi/features/news/domain/usecases/get_news.dart';
import 'package:core/core.dart' show Provider;
import 'package:core/core.dart' show injectable;
import 'package:flutter/foundation.dart';

/// Provider Riverpod para NewsProvider
///
/// Integra GetIt com Riverpod para gerenciamento de estado
final newsProviderProvider = Provider<NewsProvider>((ref) {
  return getIt<NewsProvider>();
});

/// News Provider for State Management
///
/// Manages news articles, commodity prices, and RSS feed state
/// using Provider pattern for reactive UI updates
@injectable
class NewsProvider with ChangeNotifier {
  final GetNews _getNews;
  final GetArticleById _getArticleById;
  final SearchArticles _searchArticles;
  final GetPremiumArticles _getPremiumArticles;
  final ManageFavorites _manageFavorites;
  final RefreshRSSFeeds _refreshRSSFeeds;
  final GetCommodityPrices _getCommodityPrices;
  final NewsRepository _repository;

  NewsProvider(
    this._getNews,
    this._getArticleById,
    this._searchArticles,
    this._getPremiumArticles,
    this._manageFavorites,
    this._refreshRSSFeeds,
    this._getCommodityPrices,
    this._repository,
  );

  List<NewsArticleEntity> _articles = [];
  List<NewsArticleEntity> _premiumArticles = [];
  List<NewsArticleEntity> _favoriteArticles = [];
  List<NewsArticleEntity> _searchResults = [];
  List<CommodityPriceEntity> _commodityPrices = [];
  MarketSummaryEntity? _marketSummary;

  bool _isLoadingNews = false;
  bool _isLoadingPremium = false;
  bool _isLoadingCommodities = false;
  bool _isRefreshing = false;
  bool _isSearching = false;

  String? _errorMessage;
  NewsFilter? _currentFilter;
  String _currentSearchQuery = '';

  DateTime? _lastRSSUpdate;
  List<String> _rssSources = [];

  List<NewsArticleEntity> get articles => _articles;
  List<NewsArticleEntity> get premiumArticles => _premiumArticles;
  List<NewsArticleEntity> get favoriteArticles => _favoriteArticles;
  List<NewsArticleEntity> get searchResults => _searchResults;
  List<CommodityPriceEntity> get commodityPrices => _commodityPrices;
  MarketSummaryEntity? get marketSummary => _marketSummary;

  bool get isLoadingNews => _isLoadingNews;
  bool get isLoadingPremium => _isLoadingPremium;
  bool get isLoadingCommodities => _isLoadingCommodities;
  bool get isRefreshing => _isRefreshing;
  bool get isSearching => _isSearching;

  String? get errorMessage => _errorMessage;
  NewsFilter? get currentFilter => _currentFilter;
  String get currentSearchQuery => _currentSearchQuery;

  DateTime? get lastRSSUpdate => _lastRSSUpdate;
  List<String> get rssSources => _rssSources;

  bool get hasError => _errorMessage != null;
  bool get hasData => _articles.isNotEmpty;

  /// Load news articles with optional filter
  Future<void> loadNews({
    NewsFilter? filter,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (_isLoadingNews && !refresh) return;

    _setLoadingNews(true);
    _clearError();

    try {
      final result = await _getNews(filter: filter, limit: limit);

      result.fold(
        (failure) => _setError('Erro ao carregar notícias: ${failure.message}'),
        (articles) {
          _articles = articles;
          _currentFilter = filter;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingNews(false);
    }
  }

  /// Load premium articles
  Future<void> loadPremiumNews({int limit = 10, bool refresh = false}) async {
    if (_isLoadingPremium && !refresh) return;

    _setLoadingPremium(true);
    _clearError();

    try {
      final result = await _getPremiumArticles(limit: limit);

      result.fold(
        (failure) =>
            _setError('Erro ao carregar notícias premium: ${failure.message}'),
        (articles) {
          _premiumArticles = articles;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingPremium(false);
    }
  }

  /// Search news articles
  Future<void> searchNews({
    required String query,
    NewsFilter? filter,
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
      final result = await _searchArticles(
        query: query,
        filter: filter,
        limit: limit,
      );

      result.fold((failure) => _setError('Erro na busca: ${failure.message}'), (
        articles,
      ) {
        _searchResults = articles;
        _currentSearchQuery = query;
        notifyListeners();
      });
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

  /// Get article by ID
  Future<NewsArticleEntity?> getArticleById(String id) async {
    try {
      final result = await _getArticleById(id);
      return result.fold((failure) {
        _setError('Erro ao carregar artigo: ${failure.message}');
        return null;
      }, (article) => article);
    } catch (e) {
      _setError('Erro inesperado: $e');
      return null;
    }
  }

  /// Load favorite articles
  Future<void> loadFavorites() async {
    try {
      final result = await _manageFavorites.getFavorites();

      result.fold(
        (failure) =>
            _setError('Erro ao carregar favoritos: ${failure.message}'),
        (articles) {
          _favoriteArticles = articles;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    }
  }

  /// Add article to favorites
  Future<bool> addToFavorites(String articleId) async {
    try {
      final result = await _manageFavorites.addToFavorites(articleId);

      return result.fold(
        (failure) {
          _setError('Erro ao adicionar favorito: ${failure.message}');
          return false;
        },
        (_) {
          loadFavorites();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  /// Remove article from favorites
  Future<bool> removeFromFavorites(String articleId) async {
    try {
      final result = await _manageFavorites.removeFromFavorites(articleId);

      return result.fold(
        (failure) {
          _setError('Erro ao remover favorito: ${failure.message}');
          return false;
        },
        (_) {
          loadFavorites();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
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
    if (_isRefreshing) return;

    _setRefreshing(true);
    _clearError();

    try {
      final result = await _refreshRSSFeeds();

      result.fold(
        (failure) => _setError('Erro ao atualizar feeds: ${failure.message}'),
        (_) async {
          await _updateLastRSSTime();
          await loadNews(refresh: true);
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setRefreshing(false);
    }
  }

  /// Update last RSS update time
  Future<void> _updateLastRSSTime() async {
    try {
      final result = await _repository.getLastRSSUpdate();
      result.fold((failure) => null, (lastUpdate) {
        _lastRSSUpdate = lastUpdate;
        notifyListeners();
      });
    } catch (e) {
    }
  }

  /// Get RSS sources
  Future<void> loadRSSSources() async {
    try {
      final result = await _repository.getRSSSources();
      result.fold(
        (failure) =>
            _setError('Erro ao carregar feeds RSS: ${failure.message}'),
        (sources) {
          _rssSources = sources;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    }
  }

  /// Add RSS source
  Future<bool> addRSSSource(String feedUrl) async {
    try {
      final result = await _repository.addRSSSource(feedUrl);

      return result.fold(
        (failure) {
          _setError('Erro ao adicionar feed RSS: ${failure.message}');
          return false;
        },
        (_) {
          loadRSSSources();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  /// Remove RSS source
  Future<bool> removeRSSSource(String feedUrl) async {
    try {
      final result = await _repository.removeRSSSource(feedUrl);

      return result.fold(
        (failure) {
          _setError('Erro ao remover feed RSS: ${failure.message}');
          return false;
        },
        (_) {
          loadRSSSources();
          return true;
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    }
  }

  /// Load commodity prices
  Future<void> loadCommodityPrices({
    List<CommodityType>? types,
    bool refresh = false,
  }) async {
    if (_isLoadingCommodities && !refresh) return;

    _setLoadingCommodities(true);
    _clearError();

    try {
      final result = await _getCommodityPrices(types: types);

      result.fold(
        (failure) => _setError('Erro ao carregar preços: ${failure.message}'),
        (prices) {
          _commodityPrices = prices;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoadingCommodities(false);
    }
  }

  /// Load market summary
  Future<void> loadMarketSummary() async {
    try {
      final result = await _repository.getMarketSummary();

      result.fold(
        (failure) =>
            _setError('Erro ao carregar resumo do mercado: ${failure.message}'),
        (summary) {
          _marketSummary = summary;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Erro inesperado: $e');
    }
  }

  /// Apply news filter
  void applyFilter(NewsFilter filter) {
    _currentFilter = filter;
    loadNews(filter: filter);
  }

  /// Clear current filter
  void clearFilter() {
    _currentFilter = null;
    loadNews();
  }

  /// Filter by category
  void filterByCategory(NewsCategory category) {
    final filter = NewsFilter(categories: [category]);
    applyFilter(filter);
  }

  /// Show only premium articles
  void showOnlyPremium(bool showOnly) {
    final filter = (_currentFilter ?? const NewsFilter()).copyWith(
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

  void _setLoadingNews(bool loading) {
    _isLoadingNews = loading;
    notifyListeners();
  }

  void _setLoadingPremium(bool loading) {
    _isLoadingPremium = loading;
    notifyListeners();
  }

  void _setLoadingCommodities(bool loading) {
    _isLoadingCommodities = loading;
    notifyListeners();
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
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
