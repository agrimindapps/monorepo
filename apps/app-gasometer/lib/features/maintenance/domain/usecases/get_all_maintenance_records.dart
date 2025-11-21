import 'package:core/core.dart';
import '../entities/maintenance_entity.dart';
import '../repositories/maintenance_repository.dart';


class GetAllMaintenanceRecords implements UseCase<List<MaintenanceEntity>, NoParams> {

  GetAllMaintenanceRecords(this.repository);
  final MaintenanceRepository repository;

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> call(NoParams params) async {
    return repository.getAllMaintenanceRecords();
  }
}
