import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar limites de registros de combustível

class CanAddFuelRecord implements UseCase<bool, CanAddFuelRecordParams> {
  CanAddFuelRecord(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(CanAddFuelRecordParams params) async {
    return await repository.canAddFuelRecord(params.currentCount);
  }
}
