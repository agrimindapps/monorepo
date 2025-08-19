import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

@injectable
class GetAllMaintenanceRecords implements UseCase<List<MaintenanceEntity>, NoParams> {
  final MaintenanceRepository repository;

  GetAllMaintenanceRecords(this.repository);

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> call(NoParams params) async {
    return await repository.getAllMaintenanceRecords();
  }
}