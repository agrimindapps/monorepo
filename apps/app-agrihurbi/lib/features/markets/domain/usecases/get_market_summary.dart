import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/repositories/market_repository.dart';
import 'package:core/core.dart' show injectable;

/// Get Market Summary Use Case
///
/// Retrieves market summary with top performers and statistics
class GetMarketSummary {
  final MarketRepository _repository;

  GetMarketSummary(this._repository);

  /// Execute the use case
  ResultFuture<MarketSummary> call() async {
    return await _repository.getMarketSummary();
  }
}

/// Get Top Gainers Use Case
class GetTopGainers {
  final MarketRepository _repository;

  GetTopGainers(this._repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    int limit = 10,
    MarketType? type,
  }) async {
    return await _repository.getTopGainers(limit: limit, type: type);
  }
}

/// Get Top Losers Use Case
class GetTopLosers {
  final MarketRepository _repository;

  GetTopLosers(this._repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    int limit = 10,
    MarketType? type,
  }) async {
    return await _repository.getTopLosers(limit: limit, type: type);
  }
}

/// Get Most Active Use Case
class GetMostActive {
  final MarketRepository _repository;

  GetMostActive(this._repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    int limit = 10,
    MarketType? type,
  }) async {
    return await _repository.getMostActive(limit: limit, type: type);
  }
}
