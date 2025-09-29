import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/repositories/market_repository.dart';
import 'package:injectable/injectable.dart';

/// Get Market Summary Use Case
/// 
/// Retrieves market summary with top performers and statistics
@injectable
class GetMarketSummary {
  final MarketRepository _repository;

  GetMarketSummary(_repository);

  /// Execute the use case
  ResultFuture<MarketSummary> call() async {
    return await _repository.getMarketSummary();
  }
}

/// Get Top Gainers Use Case
@injectable
class GetTopGainers {
  final MarketRepository _repository;

  GetTopGainers(_repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    int limit = 10,
    MarketType? type,
  }) async {
    return await _repository.getTopGainers(
      limit: limit,
      type: type,
    );
  }
}

/// Get Top Losers Use Case
@injectable
class GetTopLosers {
  final MarketRepository _repository;

  GetTopLosers(_repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    int limit = 10,
    MarketType? type,
  }) async {
    return await _repository.getTopLosers(
      limit: limit,
      type: type,
    );
  }
}

/// Get Most Active Use Case
@injectable
class GetMostActive {
  final MarketRepository _repository;

  GetMostActive(_repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    int limit = 10,
    MarketType? type,
  }) async {
    return await _repository.getMostActive(
      limit: limit,
      type: type,
    );
  }
}