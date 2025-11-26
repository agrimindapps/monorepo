import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'package:app_agrihurbi/features/markets/domain/entities/market_entity.dart';
import 'package:app_agrihurbi/features/markets/domain/repositories/market_repository.dart';
import 'package:dartz/dartz.dart';

/// Manage Market Favorites Use Case
///
/// Handles adding, removing, and retrieving favorite markets
class ManageMarketFavorites {
  final MarketRepository _repository;

  ManageMarketFavorites(this._repository);

  /// Get favorite markets
  ResultFuture<List<MarketEntity>> getFavorites() async {
    return await _repository.getFavoriteMarkets();
  }

  /// Add market to favorites
  ResultFuture<void> addToFavorites(String marketId) async {
    return await _repository.addToFavorites(marketId);
  }

  /// Remove market from favorites
  ResultFuture<void> removeFromFavorites(String marketId) async {
    return await _repository.removeFromFavorites(marketId);
  }

  /// Check if market is favorite
  ResultFuture<bool> isFavorite(String marketId) async {
    return await _repository.isMarketFavorite(marketId);
  }

  /// Toggle favorite status
  ResultFuture<bool> toggleFavorite(String marketId) async {
    final isFavoriteResult = await _repository.isMarketFavorite(marketId);

    return isFavoriteResult.fold((failure) => Left(failure), (
      isFavorite,
    ) async {
      if (isFavorite) {
        final removeResult = await _repository.removeFromFavorites(marketId);
        return removeResult.fold(
          (failure) => Left(failure),
          (_) => const Right(false),
        );
      } else {
        final addResult = await _repository.addToFavorites(marketId);
        return addResult.fold(
          (failure) => Left(failure),
          (_) => const Right(true),
        );
      }
    });
  }
}
