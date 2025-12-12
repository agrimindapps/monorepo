import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../repositories/premium_repository.dart';

/// UseCase for restoring previous purchases
class RestorePurchasesUseCase implements NoParamsUseCase<bool> {
  final PremiumRepository _premiumRepository;

  RestorePurchasesUseCase({required PremiumRepository premiumRepository})
    : _premiumRepository = premiumRepository;

  @override
  Future<Either<Failure, bool>> call() async {
    try {
      final result = await _premiumRepository.restorePurchases();

      return result;
    } catch (e) {
      return Left(
        ServerFailure(
          'Failed to restore purchases: ${e.toString()}',
          code: 'RESTORE_ERROR',
        ),
      );
    }
  }
}
