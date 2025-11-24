import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para restaurar compras

class RestorePurchases implements UseCase<bool, NoParams> {
  RestorePurchases(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(NoParams params) async {
    return await repository.restorePurchases();
  }
}
