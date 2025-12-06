/// Device Management Providers for app-petiveti
/// 
/// Este arquivo configura os providers de device management específicos do petiveti,
/// utilizando a implementação base do core package.
/// 
/// A lógica de negócio está toda no core. Aqui apenas:
/// - Configuramos os overrides necessários para o petiveti
/// - Re-exportamos os providers do core para uso no app
library;

import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_management_providers.g.dart';

/// Configuração de limite de dispositivos para o PetiVeti
/// Web não conta no limite, apenas dispositivos mobile (iOS/Android)
const petivetiDeviceLimitConfig = DeviceLimitConfig(
  maxMobileDevices: 3,
  maxWebDevices: -1, // Web ilimitado
  countWebInLimit: false, // Web não conta no limite
  premiumMaxMobileDevices: 10,
  allowEmulators: true,
);

/// Provider para configuração de limites específica do petiveti
/// Override do deviceLimitConfigProvider do core
@riverpod
DeviceLimitConfig petivetiDeviceLimitConfigProvider(Ref ref) {
  return petivetiDeviceLimitConfig;
}

/// Provider para o FirebaseAuthService
@riverpod
FirebaseAuthService petivetiFirebaseAuthService(Ref ref) {
  return FirebaseAuthService();
}

/// Provider para o FirebaseAnalyticsService
@riverpod
FirebaseAnalyticsService petivetiFirebaseAnalyticsService(Ref ref) {
  return FirebaseAnalyticsService();
}

/// Provider para o FirebaseDeviceService configurado para o petiveti
@riverpod
FirebaseDeviceService petivetiFirebaseDeviceService(Ref ref) {
  return FirebaseDeviceService(
    limitConfig: petivetiDeviceLimitConfig,
  );
}

/// Provider para o DeviceManagementService configurado para o petiveti
@riverpod
DeviceManagementService petivetiDeviceManagementService(Ref ref) {
  final firebaseDeviceService = ref.watch(petivetiFirebaseDeviceServiceProvider);
  final authService = ref.watch(petivetiFirebaseAuthServiceProvider);
  final analyticsService = ref.watch(petivetiFirebaseAnalyticsServiceProvider);
  
  // Usa FirebaseDeviceService como repository (implementa IDeviceRepository)
  return DeviceManagementService(
    firebaseDeviceService: firebaseDeviceService,
    authService: authService,
    analyticsService: analyticsService,
    deviceRepository: firebaseDeviceService,
  );
}

/// Provider para lista de dispositivos do usuário
@riverpod
Future<List<DeviceEntity>> petivetiUserDevices(Ref ref) async {
  final service = ref.watch(petivetiDeviceManagementServiceProvider);
  final result = await service.getUserDevices();
  
  return result.fold(
    (failure) => [],
    (devices) => devices,
  );
}

/// Provider para verificar se pode adicionar mais dispositivos
@riverpod
Future<bool> petivetiCanAddMoreDevices(Ref ref) async {
  final service = ref.watch(petivetiDeviceManagementServiceProvider);
  final result = await service.canAddMoreDevices();
  
  return result.fold(
    (failure) => false,
    (canAdd) => canAdd,
  );
}

/// Provider para estatísticas de dispositivos
@riverpod
Future<DeviceStatistics?> petivetiDeviceStatistics(Ref ref) async {
  final service = ref.watch(petivetiDeviceManagementServiceProvider);
  final result = await service.getDeviceStatistics();
  
  return result.fold(
    (failure) => null,
    (stats) => stats,
  );
}
