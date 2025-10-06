import 'package:app_agrihurbi/features/news/domain/entities/commodity_price_entity.dart';
import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';
import 'package:core/core.dart' show Failure;
import 'package:dartz/dartz.dart';

/// News Repository Interface
/// 
/// Defines contract for news and market data operations
/// Supports RSS feeds, article caching, and commodity pricing
abstract class NewsRepository {
  
  /// Fetch latest news articles with optional filtering
  Future<Either<Failure, List<NewsArticleEntity>>> getNews({
    NewsFilter? filter,
    int limit = 20,
    int offset = 0,
  });

  /// Get specific news article by ID
  Future<Either<Failure, NewsArticleEntity>> getArticleById(String id);

  /// Search articles by query
  Future<Either<Failure, List<NewsArticleEntity>>> searchArticles({
    required String query,
    NewsFilter? filter,
    int limit = 20,
  });

  /// Get articles by category
  Future<Either<Failure, List<NewsArticleEntity>>> getArticlesByCategory({
    required NewsCategory category,
    int limit = 20,
    int offset = 0,
  });

  /// Get premium articles (requires subscription)
  Future<Either<Failure, List<NewsArticleEntity>>> getPremiumArticles({
    int limit = 10,
    int offset = 0,
  });

  /// Cache article for offline reading
  Future<Either<Failure, void>> cacheArticle(NewsArticleEntity article);

  /// Get cached articles for offline reading
  Future<Either<Failure, List<NewsArticleEntity>>> getCachedArticles();

  /// Clear articles cache
  Future<Either<Failure, void>> clearCache();
  
  /// Refresh RSS feeds from all sources
  Future<Either<Failure, void>> refreshRSSFeeds();

  /// Get RSS feed update status
  Future<Either<Failure, DateTime?>> getLastRSSUpdate();

  /// Add custom RSS feed source
  Future<Either<Failure, void>> addRSSSource(String feedUrl);

  /// Remove RSS feed source
  Future<Either<Failure, void>> removeRSSSource(String feedUrl);

  /// Get all configured RSS sources
  Future<Either<Failure, List<String>>> getRSSSources();
  
  /// Get current commodity prices
  Future<Either<Failure, List<CommodityPriceEntity>>> getCommodityPrices({
    List<CommodityType>? types,
  });

  /// Get specific commodity price by ID
  Future<Either<Failure, CommodityPriceEntity>> getCommodityById(String id);

  /// Get commodity price history
  Future<Either<Failure, List<HistoricalPrice>>> getCommodityHistory({
    required String commodityId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get market summary
  Future<Either<Failure, MarketSummaryEntity>> getMarketSummary();

  /// Set price alert for commodity
  Future<Either<Failure, void>> setPriceAlert({
    required String commodityId,
    required double targetPrice,
    required bool isAbove, // true = alert when above, false = alert when below
  });

  /// Get active price alerts
  Future<Either<Failure, List<PriceAlert>>> getPriceAlerts();

  /// Remove price alert
  Future<Either<Failure, void>> removePriceAlert(String alertId);
  
  /// Add article to favorites
  Future<Either<Failure, void>> addToFavorites(String articleId);

  /// Remove article from favorites
  Future<Either<Failure, void>> removeFromFavorites(String articleId);

  /// Get favorite articles
  Future<Either<Failure, List<NewsArticleEntity>>> getFavoriteArticles();

  /// Check if article is favorited
  Future<Either<Failure, bool>> isArticleFavorite(String articleId);
}

/// Price Alert Entity
class PriceAlert {
  final String id;
  final String commodityId;
  final String commodityName;
  final double targetPrice;
  final bool isAbove;
  final DateTime createdAt;
  final bool isActive;

  const PriceAlert({
    required this.id,
    required this.commodityId,
    required this.commodityName,
    required this.targetPrice,
    required this.isAbove,
    required this.createdAt,
    this.isActive = true,
  });
}