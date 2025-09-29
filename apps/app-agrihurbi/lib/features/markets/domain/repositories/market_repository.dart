import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_filter_entity.dart';

/// Market Repository Interface
/// 
/// Defines the contract for market data operations
/// following Clean Architecture principles
abstract class MarketRepository {
  
  /// Get all markets with optional filtering
  ResultFuture<List<MarketEntity>> getMarkets({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
  });

  /// Get market by ID
  ResultFuture<MarketEntity> getMarketById(String id);

  /// Search markets by query
  ResultFuture<List<MarketEntity>> searchMarkets({
    required String query,
    MarketFilter? filter,
    int limit = 20,
  });

  /// Get markets by type
  ResultFuture<List<MarketEntity>> getMarketsByType({
    required MarketType type,
    int limit = 20,
  });

  /// Get market summary with statistics
  ResultFuture<MarketSummary> getMarketSummary();

  /// Get top gainers
  ResultFuture<List<MarketEntity>> getTopGainers({
    int limit = 10,
    MarketType? type,
  });

  /// Get top losers
  ResultFuture<List<MarketEntity>> getTopLosers({
    int limit = 10,
    MarketType? type,
  });

  /// Get most active markets
  ResultFuture<List<MarketEntity>> getMostActive({
    int limit = 10,
    MarketType? type,
  });

  /// Get market price history
  ResultFuture<List<PriceHistory>> getMarketHistory({
    required String marketId,
    required DateTime startDate,
    required DateTime endDate,
    String interval = '1d', // 1m, 5m, 15m, 30m, 1h, 4h, 1d, 1w, 1M
  });

  /// Get favorite markets
  ResultFuture<List<MarketEntity>> getFavoriteMarkets();

  /// Add market to favorites
  ResultFuture<void> addToFavorites(String marketId);

  /// Remove market from favorites
  ResultFuture<void> removeFromFavorites(String marketId);

  /// Check if market is favorite
  ResultFuture<bool> isMarketFavorite(String marketId);

  /// Get market alerts
  ResultFuture<List<MarketAlert>> getMarketAlerts();

  /// Create market alert
  ResultFuture<void> createMarketAlert(MarketAlert alert);

  /// Delete market alert
  ResultFuture<void> deleteMarketAlert(String alertId);

  /// Refresh market data (force update from remote)
  ResultFuture<void> refreshMarketData();

  /// Get supported exchanges
  ResultFuture<List<String>> getSupportedExchanges();

  /// Get market types with descriptions
  ResultFuture<List<MarketTypeInfo>> getMarketTypes();

  /// Get market news related to specific commodity
  ResultFuture<List<MarketNews>> getMarketNews({
    String? marketId,
    MarketType? type,
    int limit = 10,
  });
}

/// Market Alert Entity
class MarketAlert {
  final String id;
  final String marketId;
  final String marketName;
  final AlertType type;
  final double threshold;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  const MarketAlert({
    required id,
    required marketId,
    required marketName,
    required type,
    required threshold,
    required isActive,
    required createdAt,
    lastTriggered,
  });
}

/// Alert Types
enum AlertType {
  priceAbove('Preço Acima'),
  priceBelow('Preço Abaixo'),
  changeAbove('Variação Acima'),
  changeBelow('Variação Abaixo'),
  volumeAbove('Volume Acima');

  const AlertType(displayName);
  final String displayName;
}

/// Market Type Info
class MarketTypeInfo {
  final MarketType type;
  final String description;
  final int marketCount;
  final String iconName;

  const MarketTypeInfo({
    required type,
    required description,
    required marketCount,
    required iconName,
  });
}

/// Market News
class MarketNews {
  final String id;
  final String title;
  final String summary;
  final String? imageUrl;
  final DateTime publishedAt;
  final String source;
  final List<String> relatedMarkets;
  final MarketNewsImpact impact;

  const MarketNews({
    required id,
    required title,
    required summary,
    imageUrl,
    required publishedAt,
    required source,
    required relatedMarkets,
    required impact,
  });
}

/// Market News Impact
enum MarketNewsImpact {
  positive('Positivo'),
  negative('Negativo'),
  neutral('Neutro');

  const MarketNewsImpact(displayName);
  final String displayName;
}