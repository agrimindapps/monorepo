import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class UpdateMaintenanceRecordParams extends Equatable {

  const UpdateMaintenanceRecordParams({required this.maintenance});
  final MaintenanceEntity maintenance;

  @override
  List<Object> get props => [maintenance];
}

@injectable
class UpdateMaintenanceRecord implements UseCase<MaintenanceEntity, UpdateMaintenanceRecordParams> {

  UpdateMaintenanceRecord(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, MaintenanceEntity>> call(UpdateMaintenanceRecordParams params) async {
    return await repository.updateMaintenanceRecord(params.maintenance);
  }
}