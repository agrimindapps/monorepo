import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar limites de veículos

class CanAddVehicle implements UseCase<bool, CanAddVehicleParams> {
  CanAddVehicle(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(CanAddVehicleParams params) async {
    return await repository.canAddVehicle(params.currentCount);
  }
}
