import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class UpdateMaintenanceRecordParams extends Equatable {
  final MaintenanceEntity maintenance;

  const UpdateMaintenanceRecordParams({required this.maintenance});

  @override
  List<Object> get props => [maintenance];
}

@injectable
class UpdateMaintenanceRecord implements UseCase<MaintenanceEntity, UpdateMaintenanceRecordParams> {
  final MaintenanceRepository repository;

  UpdateMaintenanceRecord(this.repository);

  @override
  Future<Either<Failure, MaintenanceEntity>> call(UpdateMaintenanceRecordParams params) async {
    return await repository.updateMaintenanceRecord(params.maintenance);
  }
}