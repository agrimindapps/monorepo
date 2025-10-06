import 'package:core/core.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';

class AddMaintenanceRecordParams extends Equatable {
  const AddMaintenanceRecordParams({required this.maintenance});
  final MaintenanceEntity maintenance;

  @override
  List<Object> get props => [maintenance];
}

@injectable
class AddMaintenanceRecord
    implements UseCase<MaintenanceEntity, AddMaintenanceRecordParams> {
  AddMaintenanceRecord(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, MaintenanceEntity>> call(
    AddMaintenanceRecordParams params,
  ) async {
    return repository.addMaintenanceRecord(params.maintenance);
  }
}
