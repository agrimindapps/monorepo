import 'package:core/core.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class GetMaintenanceRecordsByVehicleParams extends Equatable {
  const GetMaintenanceRecordsByVehicleParams({required this.vehicleId});
  final String vehicleId;

  @override
  List<Object> get props => [vehicleId];
}


class GetMaintenanceRecordsByVehicle
    implements
        UseCase<List<MaintenanceEntity>, GetMaintenanceRecordsByVehicleParams> {
  GetMaintenanceRecordsByVehicle(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> call(
    GetMaintenanceRecordsByVehicleParams params,
  ) async {
    return repository.getMaintenanceRecordsByVehicle(params.vehicleId);
  }
}
