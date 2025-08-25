import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class AddMaintenanceRecordParams extends Equatable {
  final MaintenanceEntity maintenance;

  const AddMaintenanceRecordParams({required this.maintenance});

  @override
  List<Object> get props => [maintenance];
}

@injectable
class AddMaintenanceRecord implements UseCase<MaintenanceEntity, AddMaintenanceRecordParams> {
  final MaintenanceRepository repository;

  AddMaintenanceRecord(this.repository);

  @override
  Future<Either<Failure, MaintenanceEntity>> call(AddMaintenanceRecordParams params) async {
    return await repository.addMaintenanceRecord(params.maintenance);
  }
}