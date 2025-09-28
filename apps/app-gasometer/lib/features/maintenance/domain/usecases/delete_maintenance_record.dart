import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/maintenance_repository.dart';

class DeleteMaintenanceRecordParams extends Equatable {

  const DeleteMaintenanceRecordParams({required this.id});
  final String id;

  @override
  List<Object> get props => [id];
}

@injectable
class DeleteMaintenanceRecord implements UseCase<Unit, DeleteMaintenanceRecordParams> {

  DeleteMaintenanceRecord(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteMaintenanceRecordParams params) async {
    return await repository.deleteMaintenanceRecord(params.id);
  }
}