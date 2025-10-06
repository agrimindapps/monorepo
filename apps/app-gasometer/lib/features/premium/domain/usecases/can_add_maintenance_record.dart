import 'package:dartz/dartz.dart';
import 'package:core/core.dart' show injectable;
import 'package:core/core.dart' as core;
import '../../../../core/usecases/usecase.dart';
import '../repositories/premium_repository.dart';

/// Use case para verificar limites de registros de manutenção
@injectable
class CanAddMaintenanceRecord
    implements UseCase<bool, CanAddMaintenanceRecordParams> {
  CanAddMaintenanceRecord(this.repository);
  final PremiumRepository repository;

  @override
  Future<Either<core.Failure, bool>> call(
    CanAddMaintenanceRecordParams params,
  ) async {
    return await repository.canAddMaintenanceRecord(params.currentCount);
  }
}
