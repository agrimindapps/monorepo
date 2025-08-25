import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para obter produtos disponíveis
@injectable
class GetAvailableProducts implements UseCase<List<core.ProductInfo>, NoParams> {
  final PremiumRepository repository;

  GetAvailableProducts(this.repository);

  @override
  Future<Either<Failure, List<core.ProductInfo>>> call(NoParams params) async {
    return await repository.getAvailableProducts();
  }
}