import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../repositories/premium_repository.dart';

/// UseCase for getting the current subscription status
class GetCurrentSubscriptionUseCase
    implements NoParamsUseCase<SubscriptionEntity?> {
  final PremiumRepository _premiumRepository;

  GetCurrentSubscriptionUseCase({required PremiumRepository premiumRepository})
    : _premiumRepository = premiumRepository;

  @override
  Future<Either<Failure, SubscriptionEntity?>> call() async {
    try {
      // Get full premium status
      final statusResult = await _premiumRepository.getPremiumStatus();

      // Extract subscription from status
      return statusResult.map((status) => status.subscription);
    } catch (e) {
      return Left(
        ServerFailure(
          'Failed to get current subscription: ${e.toString()}',
          code: 'GET_SUBSCRIPTION_ERROR',
        ),
      );
    }
  }
}
