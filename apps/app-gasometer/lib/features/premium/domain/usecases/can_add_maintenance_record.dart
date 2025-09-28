import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar limites de registros de manutenção
@injectable
class CanAddMaintenanceRecord implements UseCase<bool, CanAddMaintenanceRecordParams> {

  CanAddMaintenanceRecord(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<Failure, bool>> call(CanAddMaintenanceRecordParams params) async {
    return await repository.canAddMaintenanceRecord(params.currentCount);
  }
}