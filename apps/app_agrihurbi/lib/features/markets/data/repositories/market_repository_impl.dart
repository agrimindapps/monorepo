import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/core/network/network_info.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/markets/data/datasources/market_local_datasource.dart';
import 'package:app_agrihurbi/features/markets/data/datasources/market_remote_datasource.dart';
import 'package:app_agrihurbi/features/markets/data/models/market_model.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_filter_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/failures/market_failures.dart';
import 'package:app_agrihurbi/features/markets/domain/repositories/market_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

/// Market Repository Implementation
/// 
/// Implements the market repository following Clean Architecture principles
/// with offline-first approach and caching strategies
@Injectable(as: MarketRepository)
class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource _remoteDataSource;
  final MarketLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  MarketRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  ResultFuture<List<MarketEntity>> getMarkets({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Try to get fresh data if connected
      if (await _networkInfo.isConnected) {
        try {
          final remoteMarkets = await _remoteDataSource.getMarkets(
            filter: filter,
            limit: limit,
            offset: offset,
          );
          
          // Cache the results
          await _localDataSource.cacheMarkets(remoteMarkets);
          await _localDataSource.cacheLastUpdate(DateTime.now());
          
          return Right(remoteMarkets.map((m) => m.toEntity()).toList());
        } catch (e) {
          // If remote fails, fallback to cache
          return _getCachedMarkets();
        }
      } else {
        // No connection, use cached data
        return _getCachedMarkets();
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Get cached markets with filtering applied locally
  Future<Either<MarketFailure, List<MarketEntity>>> _getCachedMarkets() async {
    try {
      final cachedMarkets = await _localDataSource.getCachedMarkets();
      
      if (cachedMarkets.isEmpty) {
        return const Left(MarketCacheFailure('Nenhum dado em cache disponível'));
      }
      
      return Right(cachedMarkets.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<MarketEntity> getMarketById(String id) async {
    try {
      // Try cached first
      final cachedMarket = await _localDataSource.getCachedMarket(id);
      
      if (await _networkInfo.isConnected) {
        try {
          final remoteMarket = await _remoteDataSource.getMarketById(id);
          await _localDataSource.cacheMarket(remoteMarket);
          return Right(remoteMarket.toEntity());
        } catch (e) {
          if (cachedMarket != null) {
            return Right(cachedMarket.toEntity());
          }
          rethrow;
        }
      } else {
        if (cachedMarket != null) {
          return Right(cachedMarket.toEntity());
        }
        return const Left(MarketNetworkFailure('Sem conexão e dados não encontrados no cache'));
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<MarketEntity>> searchMarkets({
    required String query,
    MarketFilter? filter,
    int limit = 20,
  }) async {
    try {
      // Save search query for history
      await _localDataSource.saveSearchQuery(query);
      
      if (await _networkInfo.isConnected) {
        final remoteResults = await _remoteDataSource.searchMarkets(
          query: query,
          filter: filter,
          limit: limit,
        );
        return Right(remoteResults.map((m) => m.toEntity()).toList());
      } else {
        // Search in cached data
        final cachedMarkets = await _localDataSource.getCachedMarkets();
        final filteredMarkets = cachedMarkets.where((market) {
          final matchesQuery = market.name.toLowerCase().contains(query.toLowerCase()) ||
                             market.symbol.toLowerCase().contains(query.toLowerCase());
          
          if (!matchesQuery) return false;
          
          // Apply additional filters if provided
          if (filter?.types?.isNotEmpty == true) {
            if (!filter!.types!.contains(market.type)) return false;
          }
          
          return true;
        }).take(limit).toList();
        
        return Right(filteredMarkets.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<MarketEntity>> getMarketsByType({
    required MarketType type,
    int limit = 20,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteMarkets = await _remoteDataSource.getMarketsByType(
          type: type,
          limit: limit,
        );
        return Right(remoteMarkets.map((m) => m.toEntity()).toList());
      } else {
        final cachedMarkets = await _localDataSource.getCachedMarkets();
        final filteredMarkets = cachedMarkets
            .where((m) => m.type == type)
            .take(limit)
            .toList();
        
        return Right(filteredMarkets.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<MarketSummary> getMarketSummary() async {
    try {
      if (await _networkInfo.isConnected) {
        try {
          final remoteSummary = await _remoteDataSource.getMarketSummary();
          await _localDataSource.cacheMarketSummary(remoteSummary);
          return Right(remoteSummary.toEntity());
        } catch (e) {
          // Fallback to cached summary
          final cachedSummary = await _localDataSource.getCachedMarketSummary();
          if (cachedSummary != null) {
            return Right(cachedSummary.toEntity());
          }
          rethrow;
        }
      } else {
        final cachedSummary = await _localDataSource.getCachedMarketSummary();
        if (cachedSummary != null) {
          return Right(cachedSummary.toEntity());
        }
        return const Left(MarketCacheFailure('Resumo do mercado não disponível offline'));
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<MarketEntity>> getTopGainers({
    int limit = 10,
    MarketType? type,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteMarkets = await _remoteDataSource.getTopGainers(
          limit: limit,
          type: type,
        );
        return Right(remoteMarkets.map((m) => m.toEntity()).toList());
      } else {
        final cachedMarkets = await _localDataSource.getCachedMarkets();
        var gainers = cachedMarkets.where((m) => m.isUp).toList();
        
        if (type != null) {
          gainers = gainers.where((m) => m.type == type).toList();
        }
        
        gainers.sort((a, b) => b.changePercent.compareTo(a.changePercent));
        return Right(gainers.take(limit).map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<MarketEntity>> getTopLosers({
    int limit = 10,
    MarketType? type,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteMarkets = await _remoteDataSource.getTopLosers(
          limit: limit,
          type: type,
        );
        return Right(remoteMarkets.map((m) => m.toEntity()).toList());
      } else {
        final cachedMarkets = await _localDataSource.getCachedMarkets();
        var losers = cachedMarkets.where((m) => m.isDown).toList();
        
        if (type != null) {
          losers = losers.where((m) => m.type == type).toList();
        }
        
        losers.sort((a, b) => a.changePercent.compareTo(b.changePercent));
        return Right(losers.take(limit).map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<MarketEntity>> getMostActive({
    int limit = 10,
    MarketType? type,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteMarkets = await _remoteDataSource.getMostActive(
          limit: limit,
          type: type,
        );
        return Right(remoteMarkets.map((m) => m.toEntity()).toList());
      } else {
        final cachedMarkets = await _localDataSource.getCachedMarkets();
        var activeMarkets = cachedMarkets.toList();
        
        if (type != null) {
          activeMarkets = activeMarkets.where((m) => m.type == type).toList();
        }
        
        activeMarkets.sort((a, b) => b.volume.compareTo(a.volume));
        return Right(activeMarkets.take(limit).map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<PriceHistory>> getMarketHistory({
    required String marketId,
    required DateTime startDate,
    required DateTime endDate,
    String interval = '1d',
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteHistory = await _remoteDataSource.getMarketHistory(
          marketId: marketId,
          startDate: startDate,
          endDate: endDate,
          interval: interval,
        );
        return Right(remoteHistory.map((h) => h.toEntity()).toList());
      } else {
        return const Left(MarketNetworkFailure('Histórico de preços requer conexão'));
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<MarketEntity>> getFavoriteMarkets() async {
    try {
      final favoriteIds = await _localDataSource.getFavoriteMarketIds();
      final cachedMarkets = await _localDataSource.getCachedMarkets();
      
      final favoriteMarkets = cachedMarkets
          .where((m) => favoriteIds.contains(m.id))
          .toList();
      
      return Right(favoriteMarkets.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<void> addToFavorites(String marketId) async {
    try {
      await _localDataSource.addToFavorites(marketId);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<void> removeFromFavorites(String marketId) async {
    try {
      await _localDataSource.removeFromFavorites(marketId);
      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<bool> isMarketFavorite(String marketId) async {
    try {
      final isFavorite = await _localDataSource.isMarketFavorite(marketId);
      return Right(isFavorite);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<MarketAlert>> getMarketAlerts() async {
    // TODO: Implement alerts functionality
    return const Right([]);
  }

  @override
  ResultFuture<void> createMarketAlert(MarketAlert alert) async {
    // TODO: Implement alerts functionality
    return const Right(null);
  }

  @override
  ResultFuture<void> deleteMarketAlert(String alertId) async {
    // TODO: Implement alerts functionality
    return const Right(null);
  }

  @override
  ResultFuture<void> refreshMarketData() async {
    try {
      if (await _networkInfo.isConnected) {
        await _localDataSource.clearMarketsCache();
        return const Right(null);
      } else {
        return const Left(MarketNetworkFailure('Necessária conexão para atualizar dados'));
      }
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  ResultFuture<List<String>> getSupportedExchanges() async {
    // Mock implementation - in real app, this would come from API
    return const Right(['BMF', 'CBOT', 'NYSE', 'NASDAQ']);
  }

  @override
  ResultFuture<List<MarketTypeInfo>> getMarketTypes() async {
    // Mock implementation - in real app, this would come from API/cache
    final types = MarketType.values.map((type) => MarketTypeInfo(
      type: type,
      description: type.description,
      marketCount: 10, // Mock count
      iconName: _getIconNameForType(type),
    )).toList();
    
    return Right(types);
  }

  @override
  ResultFuture<List<MarketNews>> getMarketNews({
    String? marketId,
    MarketType? type,
    int limit = 10,
  }) async {
    // TODO: Implement market news functionality
    return const Right([]);
  }

  /// Map exceptions to appropriate failures
  MarketFailure _mapExceptionToFailure(dynamic exception) {
    if (exception is ServerException) {
      return const MarketServerFailure();
    } else if (exception is NetworkException) {
      return const MarketNetworkFailure();
    } else if (exception is CacheException) {
      return const MarketCacheFailure();
    } else {
      return MarketDataFailure('Erro inesperado: $exception');
    }
  }

  /// Get icon name for market type
  String _getIconNameForType(MarketType type) {
    switch (type) {
      case MarketType.grains:
        return 'grain';
      case MarketType.livestock:
        return 'livestock';
      case MarketType.dairy:
        return 'milk';
      case MarketType.vegetables:
        return 'vegetable';
      case MarketType.fruits:
        return 'fruit';
      case MarketType.coffee:
        return 'coffee';
      case MarketType.sugar:
        return 'sugar';
      case MarketType.cotton:
        return 'cotton';
      case MarketType.fertilizer:
        return 'fertilizer';
      case MarketType.soybean:
        return 'soybean';
      case MarketType.corn:
        return 'corn';
      case MarketType.beef:
        return 'beef';
    }
  }
}