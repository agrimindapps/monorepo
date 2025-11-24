import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../database/providers/database_providers.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../../domain/services/maintenance_formatter_service.dart';
import '../../domain/usecases/add_maintenance_record.dart';
import '../../domain/usecases/update_maintenance_record.dart';

part 'maintenance_providers.g.dart';

@riverpod
MaintenanceRepository maintenanceRepository(Ref ref) {
  return ref.watch(maintenanceRepositoryProvider);
}

@riverpod
MaintenanceFormatterService maintenanceFormatterService(Ref ref) {
  return MaintenanceFormatterService();
}

@riverpod
AddMaintenanceRecord addMaintenanceRecord(Ref ref) {
  return AddMaintenanceRecord(ref.watch(maintenanceRepositoryProvider));
}

@riverpod
UpdateMaintenanceRecord updateMaintenanceRecord(Ref ref) {
  return UpdateMaintenanceRecord(ref.watch(maintenanceRepositoryProvider));
}
