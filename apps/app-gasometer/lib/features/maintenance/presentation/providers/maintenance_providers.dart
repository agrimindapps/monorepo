import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../database/providers/database_providers.dart' as db;
import '../../domain/repositories/maintenance_repository.dart';
import '../../domain/services/maintenance_formatter_service.dart';
import '../../domain/usecases/add_maintenance_record.dart';
import '../../domain/usecases/update_maintenance_record.dart';

part 'maintenance_providers.g.dart';

/// Provider do repositório de manutenção (interface do domain)
@riverpod
MaintenanceRepository maintenanceRepository(Ref ref) {
  return ref.watch(db.maintenanceDomainRepositoryProvider);
}

@riverpod
MaintenanceFormatterService maintenanceFormatterService(Ref ref) {
  return MaintenanceFormatterService();
}

@riverpod
AddMaintenanceRecord addMaintenanceRecord(Ref ref) {
  return AddMaintenanceRecord(ref.watch(db.maintenanceDomainRepositoryProvider));
}

@riverpod
UpdateMaintenanceRecord updateMaintenanceRecord(Ref ref) {
  return UpdateMaintenanceRecord(ref.watch(db.maintenanceDomainRepositoryProvider));
}
