import 'package:core/core.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class UpdateMaintenanceRecordParams extends Equatable {
  const UpdateMaintenanceRecordParams({required this.maintenance});
  final MaintenanceEntity maintenance;

  @override
  List<Object> get props => [maintenance];
}

@injectable
class UpdateMaintenanceRecord
    implements UseCase<MaintenanceEntity, UpdateMaintenanceRecordParams> {
  UpdateMaintenanceRecord(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, MaintenanceEntity>> call(
    UpdateMaintenanceRecordParams params,
  ) async {
    return repository.updateMaintenanceRecord(params.maintenance);
  }
}
