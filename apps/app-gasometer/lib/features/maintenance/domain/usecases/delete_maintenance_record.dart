import 'package:core/core.dart';
import 'package:core/core.dart' show Equatable;
import '../repositories/maintenance_repository.dart';

class DeleteMaintenanceRecordParams extends Equatable {
  const DeleteMaintenanceRecordParams({required this.id});
  final String id;

  @override
  List<Object> get props => [id];
}

@injectable
class DeleteMaintenanceRecord
    implements UseCase<Unit, DeleteMaintenanceRecordParams> {
  DeleteMaintenanceRecord(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, Unit>> call(
    DeleteMaintenanceRecordParams params,
  ) async {
    return repository.deleteMaintenanceRecord(params.id);
  }
}
