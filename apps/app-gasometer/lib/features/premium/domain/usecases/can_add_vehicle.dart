import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar limites de veículos
@injectable
class CanAddVehicle implements UseCase<bool, CanAddVehicleParams> {
  final PremiumRepository repository;

  CanAddVehicle(this.repository);

  @override
  Future<Either<Failure, bool>> call(CanAddVehicleParams params) async {
    return await repository.canAddVehicle(params.currentCount);
  }
}