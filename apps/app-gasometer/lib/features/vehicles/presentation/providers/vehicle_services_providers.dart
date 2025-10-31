import 'package:core/core.dart';

import '../../../../core/error/error_mapper.dart';
import '../../domain/services/vehicle_filter_service.dart';

part 'vehicle_services_providers.g.dart';

/// Provider para VehicleFilterService (Singleton)
@Riverpod(keepAlive: true)
VehicleFilterService vehicleFilterService(Ref ref) {
  return VehicleFilterServiceImpl();
}

/// Provider para ErrorMapper (Singleton) - Compartilhado por todo o app
@Riverpod(keepAlive: true)
ErrorMapper errorMapper(Ref ref) {
  return ErrorMapperImpl();
}
