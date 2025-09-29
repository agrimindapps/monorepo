import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_filter_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/repositories/market_repository.dart';
import 'package:injectable/injectable.dart';

/// Get Markets Use Case
/// 
/// Retrieves list of markets with optional filtering and pagination
@injectable
class GetMarkets {
  final MarketRepository _repository;

  GetMarkets(_repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    MarketFilter? filter,
    int limit = 50,
    int offset = 0,
  }) async {
    return await _repository.getMarkets(
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }
}

/// Get Markets by Type Use Case
@injectable
class GetMarketsByType {
  final MarketRepository _repository;

  GetMarketsByType(_repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    required MarketType type,
    int limit = 20,
  }) async {
    return await _repository.getMarketsByType(
      type: type,
      limit: limit,
    );
  }
}

/// Search Markets Use Case
@injectable
class SearchMarkets {
  final MarketRepository _repository;

  SearchMarkets(_repository);

  /// Execute the use case
  ResultFuture<List<MarketEntity>> call({
    required String query,
    MarketFilter? filter,
    int limit = 20,
  }) async {
    return await _repository.searchMarkets(
      query: query,
      filter: filter,
      limit: limit,
    );
  }
}