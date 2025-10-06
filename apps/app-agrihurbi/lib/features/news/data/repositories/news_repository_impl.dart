import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/core/network/network_info.dart';
import 'package:app_agrihurbi/features/news/data/datasources/news_local_datasource.dart';
import 'package:app_agrihurbi/features/news/data/datasources/news_remote_datasource.dart';
import 'package:app_agrihurbi/features/news/data/models/commodity_price_model.dart';
import 'package:app_agrihurbi/features/news/data/models/news_article_model.dart';
import 'package:app_agrihurbi/features/news/domain/entities/commodity_price_entity.dart';
import 'package:app_agrihurbi/features/news/domain/entities/news_article_entity.dart';
import 'package:app_agrihurbi/features/news/domain/repositories/news_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

/// News Repository Implementation
@LazySingleton(as: NewsRepository)
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _remoteDataSource;
  final NewsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const NewsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getNews({
    NewsFilter? filter,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        try {
          final remoteArticles = await _remoteDataSource.fetchNewsFromRSS(limit: limit);
          await _localDataSource.cacheArticles(remoteArticles);
          if (filter != null) {
            final filterModel = NewsFilterModel.fromEntity(filter);
            final filteredArticles = await _localDataSource.searchCachedArticles(
              query: filter.searchQuery ?? '',
              filter: filterModel,
              limit: limit,
            );
            return Right(filteredArticles);
          }
          
          return Right(remoteArticles);
        } catch (e) {
          final cachedArticles = await _localDataSource.getCachedArticles(
            limit: limit,
            offset: offset,
          );
          return Right(cachedArticles);
        }
      } else {
        final cachedArticles = await _localDataSource.getCachedArticles(
          limit: limit,
          offset: offset,
        );
        return Right(cachedArticles);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, NewsArticleEntity>> getArticleById(String id) async {
    try {
      final cachedArticle = await _localDataSource.getArticleById(id);
      if (cachedArticle != null) {
        return Right(cachedArticle);
      }
      return const Left(NotFoundFailure(message: 'Article not found'));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> searchArticles({
    required String query,
    NewsFilter? filter,
    int limit = 20,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        try {
          final filterModel = filter != null ? NewsFilterModel.fromEntity(filter) : null;
          final remoteResults = await _remoteDataSource.searchNews(
            query: query,
            filter: filterModel,
            limit: limit,
          );
          await _localDataSource.cacheArticles(remoteResults);
          return Right(remoteResults);
        } catch (e) {
        }
      }
      final filterModel = filter != null ? NewsFilterModel.fromEntity(filter) : null;
      final cachedResults = await _localDataSource.searchCachedArticles(
        query: query,
        filter: filterModel,
        limit: limit,
      );
      return Right(cachedResults);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getArticlesByCategory({
    required NewsCategory category,
    int limit = 20,
    int offset = 0,
  }) async {
    final filter = NewsFilter(categories: [category]);
    return await getNews(filter: filter, limit: limit, offset: offset);
  }

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getPremiumArticles({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final premiumArticles = await _remoteDataSource.fetchPremiumNews(
          limit: limit,
          offset: offset,
        );
        await _localDataSource.cacheArticles(premiumArticles);
        return Right(premiumArticles);
      } else {
        const filter = NewsFilterModel(showOnlyPremium: true);
        final cachedPremium = await _localDataSource.searchCachedArticles(
          query: '',
          filter: filter,
          limit: limit,
        );
        return Right(cachedPremium);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommodityPriceEntity>>> getCommodityPrices({
    List<CommodityType>? types,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final typeModels = types?.map((t) => CommodityTypeModel.fromEntity(t)).toList();
        final remotePrices = await _remoteDataSource.fetchCommodityPrices(types: typeModels);
        await _localDataSource.cacheCommodityPrices(remotePrices);
        return Right(remotePrices);
      } else {
        final typeModels = types?.map((t) => CommodityTypeModel.fromEntity(t)).toList();
        final cachedPrices = await _localDataSource.getCachedCommodityPrices(types: typeModels);
        return Right(cachedPrices);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, CommodityPriceEntity>> getCommodityById(String id) async {
    try {
      final cachedCommodity = await _localDataSource.getCommodityById(id);
      if (cachedCommodity != null) {
        return Right(cachedCommodity);
      }
      return const Left(NotFoundFailure(message: 'Commodity not found'));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HistoricalPrice>>> getCommodityHistory({
    required String commodityId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final history = await _remoteDataSource.fetchCommodityHistory(
          commodityId: commodityId,
          startDate: startDate,
          endDate: endDate,
        );
        return Right(history);
      } else {
        return const Left(ServerFailure(message: 'No internet connection for historical data'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, MarketSummaryEntity>> getMarketSummary() async {
    try {
      if (await _networkInfo.isConnected) {
        final marketSummary = await _remoteDataSource.fetchMarketSummary();
        await _localDataSource.cacheMarketSummary(marketSummary);
        return Right(marketSummary);
      } else {
        final cachedSummary = await _localDataSource.getCachedMarketSummary();
        if (cachedSummary != null) {
          return Right(cachedSummary);
        }
        return const Left(ServerFailure(message: 'No market data available offline'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String articleId) async {
    try {
      await _localDataSource.addToFavorites(articleId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String articleId) async {
    try {
      await _localDataSource.removeFromFavorites(articleId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getFavoriteArticles() async {
    try {
      final favorites = await _localDataSource.getFavoriteArticles();
      return Right(favorites);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isArticleFavorite(String articleId) async {
    try {
      final isFavorite = await _localDataSource.isArticleFavorite(articleId);
      return Right(isFavorite);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshRSSFeeds() async {
    try {
      if (await _networkInfo.isConnected) {
        final articles = await _remoteDataSource.fetchNewsFromRSS(limit: 50);
        await _localDataSource.cacheArticles(articles);
        await _localDataSource.saveLastRSSUpdate(DateTime.now());
        return const Right(null);
      } else {
        return const Left(ServerFailure(message: 'No internet connection to refresh RSS feeds'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastRSSUpdate() async {
    try {
      final lastUpdate = await _localDataSource.getLastRSSUpdate();
      return Right(lastUpdate);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheArticle(NewsArticleEntity article) async {
    try {
      final articleModel = NewsArticleModel.fromEntity(article);
      await _localDataSource.cacheArticles([articleModel]);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NewsArticleEntity>>> getCachedArticles() async {
    try {
      final cachedArticles = await _localDataSource.getCachedArticles();
      return Right(cachedArticles);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _localDataSource.clearArticlesCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addRSSSource(String feedUrl) async {
    try {
      await _localDataSource.addRSSFeed(feedUrl);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeRSSSource(String feedUrl) async {
    try {
      await _localDataSource.removeRSSFeed(feedUrl);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRSSSources() async {
    try {
      final sources = await _localDataSource.getRSSFeeds();
      return Right(sources);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setPriceAlert({
    required String commodityId,
    required double targetPrice,
    required bool isAbove,
  }) async {
    try {
      final alert = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'commodityId': commodityId,
        'targetPrice': targetPrice,
        'isAbove': isAbove,
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      };
      await _localDataSource.savePriceAlert(alert);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PriceAlert>>> getPriceAlerts() async {
    try {
      final alertsData = await _localDataSource.getPriceAlerts();
      final alerts = alertsData.map((data) {
        return PriceAlert(
          id: data['id'] as String? ?? '',
          commodityId: data['commodityId'] as String? ?? '',
          commodityName: data['commodityName'] as String? ?? 'Unknown',
          targetPrice: (data['targetPrice'] as num?)?.toDouble() ?? 0.0,
          isAbove: data['isAbove'] as bool? ?? false,
          createdAt: DateTime.parse(data['createdAt'] as String? ?? DateTime.now().toIso8601String()),
          isActive: data['isActive'] as bool? ?? true,
        );
      }).toList();
      return Right(alerts);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removePriceAlert(String alertId) async {
    try {
      await _localDataSource.removePriceAlert(alertId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: 'Unexpected error: $e'));
    }
  }
}
