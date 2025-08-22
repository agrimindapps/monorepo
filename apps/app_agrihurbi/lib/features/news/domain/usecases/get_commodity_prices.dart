import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/news/domain/entities/commodity_price_entity.dart';
import 'package:app_agrihurbi/features/news/domain/repositories/news_repository.dart';

/// Get Commodity Prices Use Case
/// 
/// Handles fetching current and historical commodity pricing data
@injectable
class GetCommodityPrices {
  final NewsRepository _repository;

  const GetCommodityPrices(this._repository);

  /// Get current prices for all or specific commodity types
  ResultFuture<List<CommodityPriceEntity>> call({
    List<CommodityType>? types,
  }) async {
    return await _repository.getCommodityPrices(types: types);
  }
}

/// Get Commodity by ID Use Case
@injectable
class GetCommodityById {
  final NewsRepository _repository;

  const GetCommodityById(this._repository);

  ResultFuture<CommodityPriceEntity> call(String commodityId) async {
    return await _repository.getCommodityById(commodityId);
  }
}

/// Get Commodity History Use Case
@injectable
class GetCommodityHistory {
  final NewsRepository _repository;

  const GetCommodityHistory(this._repository);

  ResultFuture<List<HistoricalPrice>> call({
    required String commodityId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.getCommodityHistory(
      commodityId: commodityId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Get Market Summary Use Case
@injectable
class GetMarketSummary {
  final NewsRepository _repository;

  const GetMarketSummary(this._repository);

  ResultFuture<MarketSummaryEntity> call() async {
    return await _repository.getMarketSummary();
  }
}

/// Manage Price Alerts Use Case
@injectable
class ManagePriceAlerts {
  final NewsRepository _repository;

  const ManagePriceAlerts(this._repository);

  /// Set price alert for commodity
  ResultVoid setPriceAlert({
    required String commodityId,
    required double targetPrice,
    required bool isAbove,
  }) async {
    return await _repository.setPriceAlert(
      commodityId: commodityId,
      targetPrice: targetPrice,
      isAbove: isAbove,
    );
  }

  /// Get active price alerts
  ResultFuture<List<PriceAlert>> getActiveAlerts() async {
    return await _repository.getPriceAlerts();
  }

  /// Remove price alert
  ResultVoid removeAlert(String alertId) async {
    return await _repository.removePriceAlert(alertId);
  }
}