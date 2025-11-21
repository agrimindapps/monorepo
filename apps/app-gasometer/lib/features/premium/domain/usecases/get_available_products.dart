import 'package:core/core.dart' as core;
import 'package:core/core.dart' show injectable;
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para obter produtos disponíveis

class GetAvailableProducts
    implements UseCase<List<core.ProductInfo>, NoParams> {
  GetAvailableProducts(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>> call(
    NoParams params,
  ) async {
    return await repository.getAvailableProducts();
  }
}
