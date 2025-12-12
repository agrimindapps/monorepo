import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../repositories/premium_repository.dart';

/// UseCase for loading available subscription products
class LoadAvailableProductsUseCase
    implements UseCase<List<ProductInfo>, LoadAvailableProductsParams> {
  final PremiumRepository _premiumRepository;

  LoadAvailableProductsUseCase({required PremiumRepository premiumRepository})
    : _premiumRepository = premiumRepository;

  @override
  Future<Either<Failure, List<ProductInfo>>> call(
    LoadAvailableProductsParams params,
  ) async {
    try {
      // Note: getAvailableProducts() não precisa de productIds no novo repository
      // O repository já conhece os produtos específicos do Plantis
      final result = await _premiumRepository.getAvailableProducts();

      return result;
    } catch (e) {
      return Left(
        ServerFailure(
          'Failed to load available products: ${e.toString()}',
          code: 'LOAD_PRODUCTS_ERROR',
        ),
      );
    }
  }
}

/// Parameters for LoadAvailableProductsUseCase
class LoadAvailableProductsParams {
  final List<String> productIds;

  const LoadAvailableProductsParams({required this.productIds});
}
