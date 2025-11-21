import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../../domain/services/maintenance_formatter_service.dart';

part 'maintenance_providers.g.dart';

@riverpod
MaintenanceRepository maintenanceRepository(Ref ref) {
  return getIt<MaintenanceRepository>();
}

@riverpod
MaintenanceFormatterService maintenanceFormatterService(Ref ref) {
  return MaintenanceFormatterService();
}
