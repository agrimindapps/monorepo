import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/features/news/data/models/commodity_price_model.dart';
import 'package:app_agrihurbi/features/news/data/models/news_article_model.dart';
import 'package:core/core.dart';

/// News Local Data Source
/// 
/// Handles local storage of news articles, favorites,
/// and commodity prices using Hive database
@injectable
class NewsLocalDataSource {
  static const String _articlesBoxName = 'news_articles';
  static const String _favoritesBoxName = 'favorite_articles';
  static const String _commoditiesBoxName = 'commodity_prices';
  static const String _marketSummaryBoxName = 'market_summary';
  static const String _rssFeedsBoxName = 'rss_feeds';
  static const String _priceAlertsBoxName = 'price_alerts';

  /// Get articles box
  Box<NewsArticleModel> get _articlesBox => Hive.box<NewsArticleModel>(_articlesBoxName);

  /// Get favorites box
  Box<String> get _favoritesBox => Hive.box<String>(_favoritesBoxName);

  /// Get commodities box
  Box<CommodityPriceModel> get _commoditiesBox => Hive.box<CommodityPriceModel>(_commoditiesBoxName);

  /// Get market summary box
  Box<MarketSummaryModel> get _marketSummaryBox => Hive.box<MarketSummaryModel>(_marketSummaryBoxName);

  /// Get RSS feeds box
  Box<String> get _rssFeedsBox => Hive.box<String>(_rssFeedsBoxName);

  /// Get price alerts box
  Box<Map<String, dynamic>> get _priceAlertsBox => Hive.box<Map<String, dynamic>>(_priceAlertsBoxName);

  /// Initialize Hive boxes
  static Future<void> initialize() async {
    await Hive.openBox<NewsArticleModel>(_articlesBoxName);
    await Hive.openBox<String>(_favoritesBoxName);
    await Hive.openBox<CommodityPriceModel>(_commoditiesBoxName);
    await Hive.openBox<MarketSummaryModel>(_marketSummaryBoxName);
    await Hive.openBox<String>(_rssFeedsBoxName);
    await Hive.openBox<Map<String, dynamic>>(_priceAlertsBoxName);
  }

  // === NEWS ARTICLES ===

  /// Cache news articles
  Future<void> cacheArticles(List<NewsArticleModel> articles) async {
    try {
      final articlesMap = <String, NewsArticleModel>{};
      for (final article in articles) {
        articlesMap[article.id] = article;
      }
      await _articlesBox.putAll(articlesMap);
    } catch (e) {
      throw CacheException('Failed to cache articles: $e');
    }
  }

  /// Get cached articles
  Future<List<NewsArticleModel>> getCachedArticles({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final articles = _articlesBox.values.toList();
      articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      
      final startIndex = offset.clamp(0, articles.length);
      final endIndex = (offset + limit).clamp(0, articles.length);
      
      return articles.sublist(startIndex, endIndex);
    } catch (e) {
      throw CacheException('Failed to get cached articles: $e');
    }
  }

  /// Get article by ID
  Future<NewsArticleModel?> getArticleById(String id) async {
    try {
      return _articlesBox.get(id);
    } catch (e) {
      throw CacheException('Failed to get article by ID: $e');
    }
  }

  /// Search cached articles
  Future<List<NewsArticleModel>> searchCachedArticles({
    required String query,
    NewsFilterModel? filter,
    int limit = 20,
  }) async {
    try {
      var articles = _articlesBox.values.where((article) {
        // Text search
        final matchesQuery = query.isEmpty ||
            article.title.toLowerCase().contains(query.toLowerCase()) ||
            article.description.toLowerCase().contains(query.toLowerCase());

        if (!matchesQuery) return false;

        // Filter by category
        if (filter?.categories.isNotEmpty == true &&
            !filter!.categories.contains(NewsCategoryModel.fromEntity(article.category))) {
          return false;
        }

        // Filter by premium status
        if (filter?.showOnlyPremium == true && !article.isPremium) {
          return false;
        }

        // Filter by date range
        if (filter?.fromDate != null && article.publishedAt.isBefore(filter!.fromDate!)) {
          return false;
        }
        if (filter?.toDate != null && article.publishedAt.isAfter(filter!.toDate!)) {
          return false;
        }

        return true;
      }).toList();

      articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return articles.take(limit).toList();
    } catch (e) {
      throw CacheException('Failed to search cached articles: $e');
    }
  }

  /// Clear articles cache
  Future<void> clearArticlesCache() async {
    try {
      await _articlesBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear articles cache: $e');
    }
  }

  // === FAVORITES ===

  /// Add article to favorites
  Future<void> addToFavorites(String articleId) async {
    try {
      await _favoritesBox.put(articleId, articleId);
    } catch (e) {
      throw CacheException('Failed to add to favorites: $e');
    }
  }

  /// Remove article from favorites
  Future<void> removeFromFavorites(String articleId) async {
    try {
      await _favoritesBox.delete(articleId);
    } catch (e) {
      throw CacheException('Failed to remove from favorites: $e');
    }
  }

  /// Check if article is favorite
  Future<bool> isArticleFavorite(String articleId) async {
    try {
      return _favoritesBox.containsKey(articleId);
    } catch (e) {
      throw CacheException('Failed to check favorite status: $e');
    }
  }

  /// Get favorite articles
  Future<List<NewsArticleModel>> getFavoriteArticles() async {
    try {
      final favoriteIds = _favoritesBox.values.toList();
      final favoriteArticles = <NewsArticleModel>[];

      for (final id in favoriteIds) {
        final article = _articlesBox.get(id);
        if (article != null) {
          favoriteArticles.add(article);
        }
      }

      favoriteArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return favoriteArticles;
    } catch (e) {
      throw CacheException('Failed to get favorite articles: $e');
    }
  }

  // === COMMODITY PRICES ===

  /// Cache commodity prices
  Future<void> cacheCommodityPrices(List<CommodityPriceModel> prices) async {
    try {
      final pricesMap = <String, CommodityPriceModel>{};
      for (final price in prices) {
        pricesMap[price.id] = price;
      }
      await _commoditiesBox.putAll(pricesMap);
    } catch (e) {
      throw CacheException('Failed to cache commodity prices: $e');
    }
  }

  /// Get cached commodity prices
  Future<List<CommodityPriceModel>> getCachedCommodityPrices({
    List<CommodityTypeModel>? types,
  }) async {
    try {
      var prices = _commoditiesBox.values.toList();

      if (types?.isNotEmpty == true) {
        prices = prices.where((price) => types!.contains(CommodityTypeModel.fromEntity(price.type))).toList();
      }

      prices.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      return prices;
    } catch (e) {
      throw CacheException('Failed to get cached commodity prices: $e');
    }
  }

  /// Get commodity by ID
  Future<CommodityPriceModel?> getCommodityById(String id) async {
    try {
      return _commoditiesBox.get(id);
    } catch (e) {
      throw CacheException('Failed to get commodity by ID: $e');
    }
  }

  /// Cache market summary
  Future<void> cacheMarketSummary(MarketSummaryModel summary) async {
    try {
      await _marketSummaryBox.put('current', summary);
    } catch (e) {
      throw CacheException('Failed to cache market summary: $e');
    }
  }

  /// Get cached market summary
  Future<MarketSummaryModel?> getCachedMarketSummary() async {
    try {
      return _marketSummaryBox.get('current');
    } catch (e) {
      throw CacheException('Failed to get cached market summary: $e');
    }
  }

  // === RSS FEEDS ===

  /// Save RSS feeds
  Future<void> saveRSSFeeds(List<String> feeds) async {
    try {
      await _rssFeedsBox.clear();
      for (int i = 0; i < feeds.length; i++) {
        await _rssFeedsBox.put(i.toString(), feeds[i]);
      }
    } catch (e) {
      throw CacheException('Failed to save RSS feeds: $e');
    }
  }

  /// Get RSS feeds
  Future<List<String>> getRSSFeeds() async {
    try {
      return _rssFeedsBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to get RSS feeds: $e');
    }
  }

  /// Add RSS feed
  Future<void> addRSSFeed(String feedUrl) async {
    try {
      final feeds = await getRSSFeeds();
      if (!feeds.contains(feedUrl)) {
        feeds.add(feedUrl);
        await saveRSSFeeds(feeds);
      }
    } catch (e) {
      throw CacheException('Failed to add RSS feed: $e');
    }
  }

  /// Remove RSS feed
  Future<void> removeRSSFeed(String feedUrl) async {
    try {
      final feeds = await getRSSFeeds();
      feeds.remove(feedUrl);
      await saveRSSFeeds(feeds);
    } catch (e) {
      throw CacheException('Failed to remove RSS feed: $e');
    }
  }

  // === PRICE ALERTS ===

  /// Save price alert
  Future<void> savePriceAlert(Map<String, dynamic> alert) async {
    try {
      final alertId = alert['id'] as String;
      await _priceAlertsBox.put(alertId, alert);
    } catch (e) {
      throw CacheException('Failed to save price alert: $e');
    }
  }

  /// Get price alerts
  Future<List<Map<String, dynamic>>> getPriceAlerts() async {
    try {
      return _priceAlertsBox.values.toList();
    } catch (e) {
      throw CacheException('Failed to get price alerts: $e');
    }
  }

  /// Remove price alert
  Future<void> removePriceAlert(String alertId) async {
    try {
      await _priceAlertsBox.delete(alertId);
    } catch (e) {
      throw CacheException('Failed to remove price alert: $e');
    }
  }

  // === METADATA ===

  /// Save last RSS update timestamp
  Future<void> saveLastRSSUpdate(DateTime timestamp) async {
    try {
      final Box<String> metadataBox = Hive.box<String>('metadata');
      await metadataBox.put('last_rss_update', timestamp.toIso8601String());
    } catch (e) {
      throw CacheException('Failed to save last RSS update: $e');
    }
  }

  /// Get last RSS update timestamp
  Future<DateTime?> getLastRSSUpdate() async {
    try {
      final Box<String> metadataBox = Hive.box<String>('metadata');
      final timestampStr = metadataBox.get('last_rss_update');
      return timestampStr != null ? DateTime.tryParse(timestampStr) : null;
    } catch (e) {
      throw CacheException('Failed to get last RSS update: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    try {
      return {
        'articles': _articlesBox.length,
        'favorites': _favoritesBox.length,
        'commodities': _commoditiesBox.length,
        'rssFeeds': _rssFeedsBox.length,
        'priceAlerts': _priceAlertsBox.length,
      };
    } catch (e) {
      throw CacheException('Failed to get cache stats: $e');
    }
  }
}